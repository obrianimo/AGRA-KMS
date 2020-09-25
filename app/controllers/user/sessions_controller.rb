class User::SessionsController < ::Devise::SessionsController
  def create
    super
    current_user.update_attribute(:logged_in, true) # avoid validations
  end

  def destroy
    current_user.update_attribute(:logged_in, false) # avoid validations
    super
  end
end