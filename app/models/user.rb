class User < ActiveRecord::Base
  has_many :streams
  has_many :tokens

  after_create :generate_token

  def self.anon
    find_by_login('anonymous')
  end

  def generate_token
    tokens.create if tokens.empty?
  end
end
