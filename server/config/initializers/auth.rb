Rails.configuration.to_prepare do
  Rails.configuration.x.auth = Rails::Application::Configuration::Custom.new

  Rails.configuration.x.auth.tap do |auth|
    auth.basic.username = ENV.fetch('AUTH_BASIC_USERNAME')
    auth.basic.password = ENV.fetch('AUTH_BASIC_PASSWORD')
    auth.bearer.token = ENV.fetch('AUTH_BEARER_TOKEN')
  end
end
