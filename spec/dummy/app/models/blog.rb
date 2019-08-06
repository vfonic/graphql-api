class Blog < ApplicationRecord
  belongs_to :author
  has_many   :blog_tags
  has_many   :tags, through: :blog_tags

  def access_name?(ctx)
    false
  end

end
