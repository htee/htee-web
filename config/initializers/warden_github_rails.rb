Warden::GitHub::Rails.setup do |config|
  config.add_scope :user, scope: 'read:org'
end
