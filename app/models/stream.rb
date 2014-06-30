class Stream < ActiveRecord::Base
  after_initialize :init

  belongs_to :user

  def init
    self.name ||= SecureRandom.hex(10)
    self.name = self.name.parameterize
  end

  def path
    "/#{user.login}/#{name}"
  end
end
