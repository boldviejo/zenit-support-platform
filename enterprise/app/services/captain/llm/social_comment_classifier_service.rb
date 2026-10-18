# Proposes a moderation decision, sentiment and topics for a social comment with a
# structured-output LLM call. In shadow mode the decision is only stored, never executed.
class Captain::Llm::SocialCommentClassifierService < Llm::BaseAiService
  include Integrations::LlmInstrumentation

  def initialize(comment:)
    super(feature: 'comment_classification', account: comment.account)
    @comment = comment
    @temperature = 0.0
  end

  def perform
    response = instrument_llm_call(instrumentation_params) do
      chat(model: @model, temperature: @temperature)
        .with_schema(Captain::SocialCommentClassificationSchema)
        .with_instructions(system_prompt)
        .ask(user_prompt)
    end

    @comment.update!(classification_attributes(parse_response(response.content)))
  end

  private

  def parse_response(content)
    return content if content.is_a?(Hash)

    JSON.parse(sanitize_json_response(content))
  end

  def classification_attributes(result)
    {
      status: :classified,
      decision: result['decision'],
      decision_reason: result['decision_reason'],
      confidence: result['confidence']&.to_f&.clamp(0.0, 1.0),
      sentiment: result['sentiment'],
      sentiment_score: result['sentiment_score']&.to_f&.clamp(-1.0, 1.0),
      topics: normalized_topics(result['topics']),
      mentions_someone: result['mentions_someone'],
      language: result['language'],
      llm_model: @model,
      classified_at: Time.current
    }
  end

  # Keeps the insights groupable: anything outside the account's topic list becomes "other"
  def normalized_topics(topics)
    Array(topics).map { |topic| allowed_topics.include?(topic) ? topic : SocialComment::OTHER_TOPIC }.uniq
  end

  def allowed_topics
    @allowed_topics ||= SocialComment.topics_for(@comment.account)
  end

  def system_prompt
    <<~PROMPT
      You moderate public comments on the Facebook and Instagram posts of the brand "#{@comment.account.name}".
      #{brand_context}
      Pick exactly one decision:
      - remove: the comment damages the brand's reputation and is not a legitimate customer issue: spam, scams or phishing,
        links promoting other businesses or competitors, hate speech, harassment, insults, obscene content,
        false or defamatory claims, or exposure of someone's personal data.
      - escalate: a legitimate complaint or bad experience a person must handle (order not received, refund, damaged or wrong item,
        bad service), even when written harshly. Never pick remove for a legitimate complaint.
      - answer: a question or request for information the brand can answer from its knowledge
        (products, sizes, prices, availability, shipping, opening hours, how to order or check an order).
      - ignore: engagement that needs no reply: praise, emojis, reactions, tagging or mentioning friends, chit-chat.

      Topics must come from this list: #{allowed_topics.join(', ')}. Return an empty list when none applies.
      Write decision_reason in #{reason_language}.
    PROMPT
  end

  def brand_context
    brand_info = @comment.account.custom_attributes['brand_info']
    "About the brand: #{brand_info.is_a?(Hash) ? brand_info.to_json : brand_info}" if brand_info.present?
  end

  def reason_language
    LANGUAGES_CONFIG.values.find { |language| language[:iso_639_1_code] == @comment.account.locale }&.dig(:name) || 'English'
  end

  def user_prompt
    <<~PROMPT
      Platform: #{@comment.platform}
      Post caption: #{@comment.post_caption.presence || 'unknown'}
      #{'This comment is a reply to another comment.' if @comment.parent_external_id.present?}
      Comment author: #{@comment.author_name}
      Comment:
      <comment>#{@comment.message}</comment>
    PROMPT
  end

  def instrumentation_params
    {
      span_name: 'llm.captain.social_comment_classifier',
      model: @model,
      temperature: @temperature,
      account_id: @comment.account_id,
      feature_name: 'comment_classification',
      messages: [
        { role: 'system', content: system_prompt },
        { role: 'user', content: user_prompt }
      ],
      metadata: { social_comment_id: @comment.id, platform: @comment.platform }
    }
  end
end
