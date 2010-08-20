require 'open-uri'
require 'feed-normalizer'

class Blog < ActiveRecord::Base
  validates_presence_of :url
  validates_uniqueness_of :url

  def entries
    feeds = FeedNormalizer::FeedNormalizer.parse(open(url.strip)).entries
    feeds.each do |feed|
      feed.date_published ||= Date.today - 100.years
    end
    feeds
  end
end

