Rails.application.middleware.insert_after Rails::Rack::Logger,
  Htee::Middleware::TokenAuth, Htee.config.auth_token