class RenameUserNameToLogin < ActiveRecord::Migration
  def change
    rename_column :users, :name, :login
  end
end
