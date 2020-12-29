class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts, id: :uuid do |t|
      t.string :title
      t.text :body
      t.boolean :published

      t.timestamps
    end
  end
end
