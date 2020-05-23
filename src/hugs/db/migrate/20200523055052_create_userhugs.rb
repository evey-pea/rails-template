class CreateUserhugs < ActiveRecord::Migration[5.2]
  def change
    create_table :userhugs do |t|
      t.references :profile, foreign_key: true
      t.references :huglist, foreign_key: true
      t.timestamps
    end
  end
end
