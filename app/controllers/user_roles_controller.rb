class UserRolesController < ApplicationController
  include Hydra::RoleManagement::UserRolesBehavior
  with_themed_layout 'dashboard'
  
  def destroy
    authorize! :remove_user, @role
    email = params[:id].sub("-dot-", ".")
    @role.users.delete(::User.find_by_email(email))
    redirect_to role_management.role_path(@role)
  end
  
end