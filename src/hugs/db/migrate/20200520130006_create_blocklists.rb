class CreateBlocklists < ActiveRecord::Migration[5.2]
  def change
    create_table :blocklists do |t|
      t.references :user, foreign_key: true
      t.integer :blocked_id

      t.timestamps
    end
  end
end
