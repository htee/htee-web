class Stream < ActiveRecord::Base
  after_initialize :init

  belongs_to :user

  def init
    self.name ||= SecureRandom.hex(10)
  end
end
