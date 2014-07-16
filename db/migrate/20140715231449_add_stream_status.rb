class AddStreamStatus < ActiveRecord::Migration
  def change
    add_column :streams, :status, :integer, default: 1
    add_index :streams, :status
  end
end
