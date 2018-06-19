class AddSheduledToTemplates < ActiveRecord::Migration[5.1]
  def change
    add_column :templates, :scheduled, :boolean
  end
end
