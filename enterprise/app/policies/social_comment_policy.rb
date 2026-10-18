class SocialCommentPolicy < ApplicationPolicy
  def index?
    true
  end

  def update?
    true
  end

  # Deleting is irreversible and public, so it is limited to administrators
  def destroy?
    @account_user.administrator?
  end

  def insights?
    true
  end
end
