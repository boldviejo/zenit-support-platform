# Aggregates the classified comments of a period for the comments insights page:
# sentiment balance, daily sentiment, recurring topics, proposed decisions and how
# often reviewers agreed with them.
class SocialComments::InsightsService
  pattr_initialize [:account!, :range!, :time_zone!]

  def perform
    totals.merge(timeline: timeline, topics: topics, review: review, topic_options: SocialComment.topics_for(account))
  end

  private

  def comments
    @comments ||= account.social_comments.in_range(range)
  end

  def classified
    comments.classified
  end

  def totals
    {
      total: comments.count,
      pending: comments.pending.count,
      failed: comments.failed.count,
      deleted: comments.where.not(deleted_at: nil).count,
      decisions: counts_for(classified.group(:decision).count, SocialComment::DECISIONS),
      sentiments: counts_for(classified.group(:sentiment).count, SocialComment::SENTIMENTS),
      platforms: counts_for(comments.group(:platform).count, SocialComment.platforms.keys)
    }
  end

  def counts_for(counts, keys)
    keys.index_with { |key| counts[key] || 0 }
  end

  def timeline
    counts = classified.group_by_day(:commented_at, time_zone: time_zone).group(:sentiment).count
    days = range.begin.in_time_zone(time_zone).to_date..range.end.in_time_zone(time_zone).to_date

    days.map do |day|
      { date: day.iso8601 }.merge(SocialComment::SENTIMENTS.index_with { |sentiment| counts[[day, sentiment]] || 0 })
    end
  end

  def topics
    totals = Hash.new { |hash, topic| hash[topic] = { topic: topic, total: 0 }.merge(SocialComment::SENTIMENTS.index_with { 0 }) }
    classified.pluck(:topics, :sentiment).each do |comment_topics, sentiment|
      comment_topics.each do |topic|
        totals[topic][:total] += 1
        totals[topic][sentiment] += 1 if sentiment
      end
    end
    totals.values.sort_by { |topic| -topic[:total] }
  end

  def review
    reviewed = classified.where.not(reviewed_decision: nil)
    { reviewed: reviewed.count, agreed: reviewed.where('reviewed_decision = decision').count }
  end
end
