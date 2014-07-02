class User < ActiveRecord::Base
  has_many :streams
  has_many :tokens

  after_create :generate_token

  def generate_token
    tokens.create if tokens.empty?
  end
end
