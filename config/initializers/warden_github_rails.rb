Warden::GitHub::Rails.setup do |config|
  config.add_scope :user, redirect_uri: '/signin', scope: 'read:org'
end
