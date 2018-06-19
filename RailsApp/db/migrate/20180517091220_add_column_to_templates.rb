class AddColumnToTemplates < ActiveRecord::Migration[5.1]
  def change
    add_column :templates, :Headless, :boolean
  end
end
