require 'open-uri'
require 'rss'

class Blog < ActiveRecord::Base
  validates_presence_of :url
  validates_uniqueness_of :url

  def entries
    content = open(url).read
    feeds = RSS::Parser.parse(content, false)
    feeds.channel.items
  end
end

