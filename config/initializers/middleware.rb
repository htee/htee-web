Rails.application.middleware.insert_after Rails::Rack::Logger,
  Htee::Middleware::TokenAuth, Htee.config.auth_token
Rails.application.middleware.insert_after Rails::Rack::Logger,
  Htee::Middleware::FixForwardedHeaders
Rails.application.middleware.insert_after Rails::Rack::Logger,
  Htee::Middleware::BasicAuth
