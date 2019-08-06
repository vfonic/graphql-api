# frozen_string_literal: true

class CreateBlogTags < ActiveRecord::Migration[5.0]
  def change
    create_table :blog_tags do |t|
      t.string :name
      t.references :tag, foreign_key: true
      t.references :blog, foreign_key: true

      t.timestamps
    end
  end
end
