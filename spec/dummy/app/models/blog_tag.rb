class BlogTag < ApplicationRecord
  belongs_to :tag
  belongs_to :blog
end
