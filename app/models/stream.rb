class Stream < ActiveRecord::Base
  after_initialize :init

  def init
    self.name ||= SecureRandom.hex(10)
  end
end
