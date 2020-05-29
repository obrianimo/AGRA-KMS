class UsersController < ApplicationController
#  include Hydra::UsersControllerBehavior
#  before_action :authenticate_user!
  with_themed_layout 'dashboard'
  before_action :authorize_admin, except: [:show, :user_pwd_change, :user_pwd_update]
  
  prepend_before_action :find_user, except: [:index, :search, :active_users, :notifications_number, :new, :create, :admin_edit, :admin_update, :destroy, :admin_pwd, :admin_pwd_update, :user_pwd_change, :user_pwd_update]
  before_action :authenticate_user!, only: [:edit, :update, :follow, :unfollow, :toggle_trophy, :new, :create]
  
  # users need to access their profile pages, so we don't authorize_admin on :show.
  # but we don't want users accessing other people's profile pages via url manipulation
  def show
    current_email = current_user.email
    if !current_user.admin? && current_email.gsub(".","-dot-") != params[:id]
      flash.keep[:notice] = 'You must be an administrator to access that feature.'
      redirect_to '/'
    end
    super
  end
  
  # GET /user_mgmt/new
  def new
    @user = User.new
  end

  # GET /user_mgmt/index
  def admin_edit
    @user = User.find_by_id(params[:user_id])
  end
  
  # GET /user_mgmt/pwd
  def admin_pwd
    @user = User.find_by_id(params[:user_id])
    @user.validate_pwd = true
  end
  
  # GET /user_mgmt/pwd_change
  def user_pwd_change
    @user = User.find_by_id(params[:user_id])
    @user.validate_pwd = true
  end
  
  # POST /groups
  def create
    @user = User.new(email: params[:user][:email], display_name: params[:user][:display_name], admin: params[:user][:admin], password: params[:user][:password], password_confirmation: params[:user][:password_confirmation])
    if @user.save
      # if the admin checkbox is checked, set up the role to make the user an admin
      if params[:user][:admin] == "1"
        add_user_to_admin_role(@user)
      end
      # Notify the user via email that an account has been created
      @user.new_account_notification
      flash.keep[:notice] = 'A user account for "' + params[:user][:email] + '" was successfully created.'
      redirect_to '/users'
    else
      render :new
    end
  end

  # when an admin updates a user's email or display name
  def admin_update
    @user = User.find_by_id(params[:user_id])
    if @user.update(email: params[:user][:email], display_name: params[:user][:display_name], admin: params[:user][:admin])
      if params[:user][:admin] == "1"
        add_user_to_admin_role(@user)
      else
        delete_user_from_admin_role(@user)
      end
      flash.keep[:notice] = 'The "' + params[:user][:email] + '" account was successfully updated.'
      redirect_to '/users'
    else
      render :admin_edit
    end
  end

  # when an admin updates a user's password
  def admin_pwd_update
    @user = User.find_by_id(params[:user_id])
    @user.validate_pwd = true
    if @user.update(email: params[:user][:email], password: params[:user][:password], password_confirmation: params[:user][:password_confirmation])
      # if an admin is updating her own password, we need to get around Devise's automatic sign out
      if @user.id == current_user.id
        sign_in(@user, :bypass => true)
      end
      flash.keep[:notice] = 'The password for "' + params[:user][:email] + '" was successfully updated.'
      redirect_to '/users'
    else
      render :admin_pwd
    end
  end

  def user_pwd_update
    @user = User.find_by_id(params[:user_id])
    @user.validate_pwd = true
    if @user.update(email: params[:user][:email], password: params[:user][:password], password_confirmation: params[:user][:password_confirmation])
      # if an admin -- for some inexplicable reason -- accesses a user's profile page via the url, we need this check
      if @user.id == current_user.id
        sign_in(@user, :bypass => true)
      end
      flash.keep[:notice] = 'The password for "' + params[:user][:email] + '" was successfully updated.'
      redirect_to sufia.profile_path(@user)
    else
      render :user_pwd_change
    end
  end

  # DELETE /user_mgmt/delete
  def destroy
    @user = User.find_by_id(params[:user_id])
    delete_user_from_admin_role(@user)
    @user.destroy
    redirect_to '/users', notice: 'The user was successfully deleted.'
  end

  def active_users
    @users =  User.all
    @active_users = []
    @users.each do |user|
      if user.logged_in
        x = Time.now.utc - user.last_request_at
        if x < Devise.timeout_in
          @active_users << user
        end
      end
    end
    render :active_users
  end

  protected
  
  def add_user_to_admin_role(user)
    @role = Role.find_by_id(1)
    @role.users << user unless @role.users.include?(user)
    @role.save    
  end

  def delete_user_from_admin_role(user)
    @role = Role.find_by_id(1)
    if @role.users.include?(user)
      @role.users.destroy(user)
      @role.save    
    end
  end

  def validate_pwd
    false
  end
  
  def sort_value
    sort = params[:sort].blank? ? "email" : params[:sort]
    case sort
    when "email"
      "email"
    when "email desc"
      "email DESC"
    when "name"
      "display_name"
    when "name desc"
      "display_name DESC"
    else
      sort
    end
  end
  
end