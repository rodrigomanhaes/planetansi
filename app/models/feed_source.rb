require 'feedzirra'

class FeedSource < ActiveRecord::Base
  validates_presence_of :url
  validates_uniqueness_of :url

  def entries
    feeds = Feedzirra::Feed.fetch_and_parse(url)
    feeds.entries
  end

  def self.blogs
    find_all_by_feed_type 'Blog'
  end

  def self.githubs
    find_all_by_feed_type 'Github'
  end

  FEED_TYPES = %w{Blog Github}
end

