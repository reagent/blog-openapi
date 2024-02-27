require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
# require "active_job/railtie"
require 'active_record/railtie'
# require "active_storage/engine"
require 'action_controller/railtie'
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require 'action_view/railtie'
# require "action_cable/engine"
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

class RequestSchemaValidationError < Committee::ValidationError
  def error_body
    { message: }
  end
end

module BlogOpenapi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    openapi_schema_file = Rails.root.join('..', 'spec', 'openapi', 'openapi.yaml')

    config.middleware.use Committee::Middleware::RequestValidation,
                          schema_path: openapi_schema_file,
                          strict_reference_validation: true,
                          coerce_date_times: true,
                          error_class: RequestSchemaValidationError,
                          strict: true

    unless Rails.env.production?
      config.middleware.use Committee::Middleware::ResponseValidation,
                            schema_path: openapi_schema_file,
                            strict_reference_validation: true,
                            validate_success_only: false,
                            strict: true
    end
  end
end
