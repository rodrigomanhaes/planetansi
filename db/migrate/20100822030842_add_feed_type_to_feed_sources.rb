class AddFeedTypeToFeedSources < ActiveRecord::Migration
  def self.up
    change_table :feed_sources do |t|
      t.string :feed_type
    end
  end

  def self.down
    change_table :feed_sources do |t|
      t.remove :feed_type
    end
  end
end

