module Authorization
  extend ActiveSupport::Concern

  def authorize_owner!(resource)
    unless resource_owner?(resource)
      flash[:alert] = "You are not authorized to do that."
      redirect_to root_path
    end
  end

  private

  def resource_owner?(resource)
    resource.user_id == current_user.id
  end
end
