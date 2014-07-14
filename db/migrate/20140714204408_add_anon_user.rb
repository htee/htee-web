class AddAnonUser < ActiveRecord::Migration
  def change
    User.create(login: 'anonymous')
  end
end
