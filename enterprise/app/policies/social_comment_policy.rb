class SocialCommentPolicy < ApplicationPolicy
  def index?
    true
  end

  def update?
    true
  end

  def insights?
    true
  end
end
