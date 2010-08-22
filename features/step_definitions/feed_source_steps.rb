Given /^the following feed_sources?:$/ do |feed_sources|
  FeedSource.create!(feed_sources.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) feed_source$/ do |pos|
  visit feed_sources_path
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following feed_sources:$/ do |expected_feed_sources_table|
  expected_feed_sources_table.diff!(tableish('table tr', 'td,th'))
end

