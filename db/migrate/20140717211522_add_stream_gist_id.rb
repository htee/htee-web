class AddStreamGistId < ActiveRecord::Migration
  def change
    add_column :streams, :gist_id, :string
  end
end
