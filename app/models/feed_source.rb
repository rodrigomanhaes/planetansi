require 'open-uri'
require 'rss'

class FeedSource < ActiveRecord::Base
  validates_presence_of :url
  validates_uniqueness_of :url

  def entries
    content = open(url).read
    feeds = RSS::Parser.parse(content, false)
    feeds.channel.items
  end

  def self.blogs
    find_all_by_feed_type 'Blog'
  end

  def self.githubs
    find_all_by_feed_type 'Github'
  end

  FEED_TYPES = %w{Blog Github}
end

