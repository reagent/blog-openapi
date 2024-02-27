class Post < ApplicationRecord
  validates :title, :body, presence: true

  scope :published, -> { where(published_at: ...Time.zone.now) }

  def publish!
    update!(published_at: Time.zone.now) unless published?
  end

  def unpublish!
    update!(published_at: nil)
  end

  def published?
    published_at? && published_at < Time.zone.now
  end
end
