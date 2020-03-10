require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AgraKms
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.autoload_paths += Dir["#{config.root}/lib/**/*"]
    config.autoload_paths += %W(#{config.root}/app/models/concerns)

    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'local_env.yml')
      YAML.load(File.open(env_file)).each do |key, value|
        ENV[key.to_s] = value
      end if File.exists?(env_file)
    end
    config.redis_namespace = 'agrakms'
    config.generators do |g|
      g.test_framework :rspec, :spec => true
    end
          
    config.to_prepare do
      Hyrax::WorksControllerBehavior.prepend PrependedControllers::WorksControllerBehavior
      # Hyrax::HomepageController.prepend PrependedControllers::HomepageController
      # Hyrax::Dashboard::CollectionsController.prepend PrependedControllers::CollectionsController
      # Hyrax::Forms::CollectionForm.prepend PrependedForms::CollectionForm
      # Hyrax::CollectionPresenter.prepend PrependedPresenters::CollectionPresenter
      # Hyrax::CollectionIndexer.prepend PrependedIndexers::CollectionIndexer
    end  
  end
end
