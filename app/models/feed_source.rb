require 'feedzirra'

class FeedSource < ActiveRecord::Base
  validates_presence_of :url
  validates_uniqueness_of :url

  def entries
    feeds = Feedzirra::Feed.fetch_and_parse(url)
    begin
      feeds.entries.each do |entry|
        entry.author = entry.author.split('(')[1].chop if entry.author.include?('(')
        entry.content = entry.summary unless entry.content.present?
      end
      feeds.entries.reject do |entry|
        github? &&
        (entry.title =~ /started following/ ||
         entry.title =~ /started watching/)
      end
    rescue NoMethodError
      nil
    end
  end

  def self.blogs
    handle(find_all_by_feed_type 'Blog')
  end

  def self.githubs
    handle(find_all_by_feed_type 'Github')
  end

  FEED_TYPES = %w{Blog Github}

  private

  def github?
    feed_type == 'Github'
  end

  def self.handle(raw_entries)
    raw_entries.
      map(&:entries).
      flatten.
      compact.
      sort_by(&:published).
      reverse
  end
end

