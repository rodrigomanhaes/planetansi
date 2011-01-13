require 'spec_helper'
require 'feedzirra'

class FakeEntry
  def initialize(options)
    @author = options[:author] || "anything"
    @content = options[:content]
    @published = options[:published]
    @title = options[:title]
    @summary = options[:summary]
  end

  attr_accessor :author, :content, :published, :summary, :title

  def to_ary; nil; end
end

describe FeedSource do
  context 'validations' do
    should_validate_presence_of :url
    should_validate_uniqueness_of :url
  end

  def stub_feed
    @entries_result = [FakeEntry.new(:author => "",
                                     :content => "need to have something here")]
    stub(:entries => @entries_result)
  end


  context 'entries' do
    it 'passes url to library' do
      feed_source = FeedSource.new :url => 'some_url'
      Feedzirra::Feed.should_receive(:fetch_and_parse).with('some_url').
                      and_return(stub_feed)
      feed_source.entries
    end

    it 'returns the entries' do
      Feedzirra::Feed.should_receive(:fetch_and_parse).
                      and_return(stub_feed)
      subject.entries.should == @entries_result
    end
  end

  context 'entries handling' do
    def stub_published(count = 1, value = Time.now)
      result = Array.new(count) { FakeEntry.new(:published => value) }
      count == 1 ? result.first : result
    end

    before :each do
      @fs1 = FeedSource.new :url => 'my_feed'
      @fs2 = FeedSource.new :url => 'my_other_feed'
      FeedSource.stub(:find_all_by_feed_type).and_return([@fs1, @fs2])
    end

    it 'maps the entries' do
      @fs1.stub(:entries).and_return(s1 = stub_published)
      @fs2.stub(:entries).and_return(s2 = stub_published)
      FeedSource.blogs.should include(s1, s2)
    end

    it 'returns all feeds in a flattened fashion' do
      @fs1.stub(:entries).and_return((s1, s2, s3 = stub_published(3)))
      @fs2.stub(:entries).and_return((s4, s5, s6 = stub_published(3)))
      FeedSource.blogs.should include(s1, s2, s3, s4, s5, s6)
    end

    it 'removes nil entries' do
      @fs1.stub(:entries).and_return([(s1, s2 = stub_published(2)), nil].flatten)
      @fs2.stub(:entries).and_return([s4 = stub_published, nil, s6 = stub_published])
      FeedSource.blogs.should include(s1, s2, s4, s6)
      FeedSource.blogs.should have(4).items
    end

    it 'sorts descending by the "published" field' do
      def s(days)
        FakeEntry.new(:published => Date.today + days.days)
      end

      @fs1.stub(:entries).and_return([s0 = s(0), s2 = s(2), s_1 = s(-1)])
      @fs2.stub(:entries).and_return([s10 = s(10), s_299 = s(-299), s3 = s(3)])
      FeedSource.blogs.should == [s10, s3, s2, s0, s_1, s_299]
    end
  end

  context 'github' do
    def fake_entry(description)
      FakeEntry.new(:title => description)
    end

    it 'does not distribute feeds about followings and watchings' do
      feed_source = FeedSource.new :url => 'some_url'
      Feedzirra::Feed.stub(:fetch_and_parse).with('some_url').
        and_return(stub(:entries => [entry_stub = fake_entry('nada'),
                                     fake_entry('martinfowler started following planetansi'),
                                     fake_entry('linustorvalds started watching planetansi')]))
      feed_source.feed_type = 'Blog'
      feed_source.should have(3).entries

      feed_source.feed_type = 'Github'
      feed_source.should have(1).entries
      feed_source.entries.should == [entry_stub]
    end
  end

  context 'handling idiosyncrasies' do
    def ensure_idiosyncrasy(entry_options)
      feed_source = FeedSource.new :url => 'some_url'
      feed_source.feed_type = entry_options.delete(:feed_type) if entry_options.has_key?(:feed_type)
      entry = FakeEntry.new(entry_options)
      Feedzirra::Feed.should_receive(:fetch_and_parse).with('some_url').
                      and_return(stub(:entries => [entry]))
      feed_source.entries
      yield(entry)
    end

    context 'parentheses in author field' do
      # blogger gives author in the form "e-mail (name)"
      it 'removes text parentheses and e-mail if exist' do
        ensure_idiosyncrasy(:author => 'rodrigo@fanatismoindeciso.com (rodrigo manhaes)') do |entry|
          entry.author.should == 'rodrigo manhaes'
        end
      end

      it 'does not modify author if there is not any parenthesis' do
        ensure_idiosyncrasy(:author => 'rodrigo manhaes') do |entry|
          entry.author.should == 'rodrigo manhaes'
        end
      end
    end

    context 'content vs summary' do
      # blogger puts whole text in 'content' field, and part of it in 'summary'
      # wordpress puts whole text in 'summary' field and nothing in 'content'
      it 'replaces content by summary if content is not present' do
        ensure_idiosyncrasy(:content => "", :summary => 'a summary') do |entry|
          entry.content.should == 'a summary'
        end
      end

      it 'does not modify content if it is present' do
        ensure_idiosyncrasy(:content => "I'm present, therefore I am!") do |entry|
          entry.content.should == "I'm present, therefore I am!"
        end
      end
    end

    context 'published is string' do
      it 'converts published to date time' do
        ensure_idiosyncrasy(:published => '03 Oct 2008 13:48:00 +0000') do |entry|
          entry.published.should == DateTime.parse('03 Oct 2008 13:48:00 +0000')
        end
      end
    end

    context 'relative github links' do
      it 'converts /something links into https://github.com/something' do
        ensure_idiosyncrasy(:content => '<a href="/something">who cares?</a>',
                            :feed_type => 'Github') do |entry|
          entry.content.should == '<a href="https://github.com/something">who cares?</a>'
        end
      end

      it 'leaves content unchanged for non-github feeds' do
          ensure_idiosyncrasy(:content => '<a href="/something">who cares?</a>',
                            :feed_type => 'other') do |entry|
          entry.content.should == '<a href="/something">who cares?</a>'
        end
      end
    end
  end

  context 'something wrong happens' do
    it 'gracefully returns nil for a shitty feed object' do
      object_that_doesnt_have_entries = Object.new
      Feedzirra::Feed.stub(:fetch_and_parse).
                      and_return(object_that_doesnt_have_entries)
      feed_source = FeedSource.new :url => 'some_url'
      feed_source.entries.should be_nil
    end
  end

  before :each do
    FeedSource.create! :url => 'http://a.com/feed', :feed_type => 'Blog'
  end
end

