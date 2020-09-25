class User < ActiveRecord::Base

  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Hyrax behaviors.
  include Hyrax::User
  include Hyrax::UserUsageStats

  # Connects this user object to Role-management behaviors. 
  include Hydra::RoleManagement::UserRoles
  include AgraKms::UserRoles

    if Blacklight::Utils.needs_attr_accessible?
      attr_accessible :email, :password, :password_confirmation
    end
    
    attr_accessor :validate_pwd

#  attr_accessible :email, :password, :password_confirmation if Rails::VERSION::MAJOR < 4
# Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :registerable,
  devise :database_authenticatable, :recoverable, :rememberable, 
         :trackable, :validatable, :timeoutable

  Warden::Manager.before_logout do |user, auth, opts|
    user.update_attribute(:logged_in, false)
  end
  validates_presence_of :password, :password_confirmation, on: :create
  validates_confirmation_of :password, on: :create
  validates_presence_of :password, :password_confirmation, on: :update, if: :validate_pwd
  validates_confirmation_of :password, on: :update, if: :validate_pwd
#  validate :pwd_update_presence

  class << self
    def currently_logged_in(logged_in = true)
      where(logged_in: logged_in).where("last_request_at > ?", Time.zone.now - timeout_in.seconds)
    end
  end
  
  def currently_logged_in?
    logged_in? && last_request_at.present? && !timedout?(last_request_at)
  end
  
  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end
  
  def name
      if display_name == nil || display_name.empty?
        user_key
      else 
        display_name
      end
  end
  
  def new_account_notification
    token = set_reset_password_token
    send_devise_notification(:send_account_notification, token, {})
  end
  
end