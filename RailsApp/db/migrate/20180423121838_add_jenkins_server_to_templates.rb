class AddJenkinsServerToTemplates < ActiveRecord::Migration[5.1]
  def change
    add_column :templates, :jenkinsServer, :string
  end
end
