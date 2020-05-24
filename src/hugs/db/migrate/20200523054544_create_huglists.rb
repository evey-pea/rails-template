class CreateHuglists < ActiveRecord::Migration[5.2]
  def change
    create_table :huglists do |t|
      t.string :hugtype
      t.timestamps
    end
  end
end
