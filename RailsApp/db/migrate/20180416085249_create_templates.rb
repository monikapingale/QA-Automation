class CreateTemplates < ActiveRecord::Migration[5.1]
  def change
    create_table :templates do |t|
      t.string :Name
      t.json :Project
      t.json :Suit
      t.json :Section
      t.json :Browser
      t.json :Profile
      t.string :Job , array:true

      t.timestamps
    end
  end
end
