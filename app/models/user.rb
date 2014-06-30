class User < ActiveRecord::Base
  has_many :streams
end
