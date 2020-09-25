class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior

  # Adds Hyrax behaviors into the application controller
  include Hyrax::Controller
  include Hyrax::ThemedLayoutController
  with_themed_layout '1_column'

  protect_from_forgery with: :exception
  
  before_action :record_user_action
  
  def record_user_action

      if current_user
        last_request_at = user_session["last_request_at"]

        if last_request_at.is_a? Integer
          last_request_at = Time.at(last_request_at).utc
        elsif last_request_at.is_a? String
          last_request_at = Time.parse(last_request_at)
        end
        # don't run the validations
        current_user.update_attribute(:last_request_at, last_request_at) # avoid validations
      end
      
  end
    
  protected

  def authorize_admin
        if !current_user.admin?
          flash.keep[:notice] = 'You must be an administrator to access this feature.'
          redirect_to root_path 
        else
          return
        end
  end
end
