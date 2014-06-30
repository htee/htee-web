class AddUserRefToStreams < ActiveRecord::Migration
  def change
    add_reference :streams, :user, index: true
  end
end
