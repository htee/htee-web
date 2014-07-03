class Token < ActiveRecord::Base
  after_initialize :init

  belongs_to :user

  def init
    self.key ||= SecureRandom.hex
  end
end
