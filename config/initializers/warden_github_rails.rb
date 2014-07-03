Warden::GitHub::Rails.setup do |config|
  config.add_scope :user, scope: 'user:email,read:org'
end
