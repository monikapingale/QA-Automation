class ChangeTypeTo < ActiveRecord::Migration[5.1]
  def change
    rename_column :environments, :type , :env_type
  end
end
