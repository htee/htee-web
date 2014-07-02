class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.string :key, limit: 32
      t.string :label
      t.references :user, index: true

      t.timestamps
    end
    add_index :tokens, :key, unique: true
  end
end
