class Captain::SocialCommentClassificationSchema < RubyLLM::Schema
  string :decision, enum: SocialComment::DECISIONS, description: 'What the brand should do with the comment'
  string :decision_reason, description: 'One short sentence explaining the decision, written in the requested language'
  number :confidence, description: 'Confidence in the decision, from 0 (guessing) to 1 (certain)'
  string :sentiment, enum: SocialComment::SENTIMENTS, description: 'Overall sentiment of the comment towards the brand'
  number :sentiment_score, description: 'Sentiment from -1 (very negative) to 1 (very positive)'
  array :topics, description: 'Allowed topics the comment is about; empty when none applies' do
    string
  end
  boolean :mentions_someone, description: 'True when the comment mainly tags or mentions other people'
  string :language, description: 'ISO 639-1 code of the language the comment is written in'
end
