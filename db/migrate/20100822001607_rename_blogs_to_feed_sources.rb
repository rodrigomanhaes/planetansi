class RenameBlogsToFeedSources < ActiveRecord::Migration
  def self.up
    rename_table :blogs, :feed_sources
  end

  def self.down
    rename_table :feed_sources, :blogs
  end
end

