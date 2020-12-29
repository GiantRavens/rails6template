class DropCreatedAtFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :created_at
    remove_column :users, :updated_at
  end
end
