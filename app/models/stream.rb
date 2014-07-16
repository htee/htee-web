class Stream < ActiveRecord::Base
  after_initialize :init

  belongs_to :user

  enum status: {
    :created => 0,
    :opened  => 1,
    :closed  => 2,
  }

  def init
    self.name ||= SecureRandom.hex(10)
    self.name = self.name.parameterize
  end

  def owner
    user.login
  end

  def nwo
    "#{owner}/#{name}"
  end

  def path
    "/#{nwo}"
  end
end
