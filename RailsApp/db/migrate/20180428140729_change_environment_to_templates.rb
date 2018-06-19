class AddEnvironmentToTemplates < ActiveRecord::Migration[5.1]
  def change
    change_column :templates, :Job

  end
end
