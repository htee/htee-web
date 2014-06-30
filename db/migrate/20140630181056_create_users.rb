class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, limit: 39

      t.timestamps
    end
    add_index :users, :name, unique: true
  end
end
