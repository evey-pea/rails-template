class CreateProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :profiles do |t|
      t.references :user, foreign_key: true
      t.string :name_first
      t.string :name_second
      t.string :name_display
      t.text :description
      t.string :street_number
      t.string :road
      t.string :suburb
      t.string :city
      t.string :state
      t.string :postcode
      t.string :country

      t.timestamps
    end
  end
end
