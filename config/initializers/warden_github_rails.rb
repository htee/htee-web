Warden::GitHub::Rails.setup do |config|
  config.add_scope :user,
    scope: 'user:email,read:org,gist',
    client_id: Htee.config.client_id,
    client_secret: Htee.config.client_secret
end
