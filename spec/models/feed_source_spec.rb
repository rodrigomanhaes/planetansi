require 'spec_helper'
require 'feedzirra'

describe FeedSource do
  context 'validations' do
    should_validate_presence_of :url
    should_validate_uniqueness_of :url
  end

  def stub_feed
    @entries_result = [stub(:author => "",
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
      result = Array.new(count) { stub(:published => value) }
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
        stub(:published => Date.today + days.days)
      end

      @fs1.stub(:entries).and_return([s0 = s(0), s2 = s(2), s_1 = s(-1)])
      @fs2.stub(:entries).and_return([s10 = s(10), s_299 = s(-299), s3 = s(3)])
      FeedSource.blogs.should == [s10, s3, s2, s0, s_1, s_299]
    end
  end

  context 'handling idiosyncrasies' do

    context 'parentheses in author field' do
      # blogger gives author in the form "e-mail (name)"
      it 'removes text parentheses and e-mail if exist' do
        feed_source = FeedSource.new :url => 'some_url'
        Feedzirra::Feed.should_receive(:fetch_and_parse).with('some_url').
                        and_return(stub(:entries => [entries_mock = stub(
                            :author => 'rodrigo@fanatismoindeciso.com (rodrigo manhaes)',
                            :content => "doesn't matter")]))
        entries_mock.should_receive(:author=).with('rodrigo manhaes')
        feed_source.entries
      end

      it 'does not modify author if there is not any parenthesis' do
        feed_source = FeedSource.new :url => 'some_url'
        Feedzirra::Feed.should_receive(:fetch_and_parse).with('some_url').
                        and_return(stub(:entries => [entries_mock = stub(
                            :author => 'rodrigo manhaes',
                            :content => "doesn't matter")]))
        entries_mock.should_not_receive(:author=)
        feed_source.entries
      end
    end

    context 'content vs summary' do
      # blogger puts whole text in 'content' field, and part of it in 'summary'
      # wordpress puts whole text in 'summary' field and nothing in 'content'
      it 'replaces content by summary if content is not present' do
        feed_source = FeedSource.new :url => 'some_url'
        Feedzirra::Feed.should_receive(:fetch_and_parse).with('some_url').
                  and_return(stub(:entries => [entries_mock = stub(
                      :content => "",
                      :summary => 'a summary',
                      :author => "doesn't matter")]))
        entries_mock.should_receive(:content=).with('a summary')
        feed_source.entries
      end

      it 'does not modify content if it is present' do
        feed_source = FeedSource.new :url => 'some_url'
        Feedzirra::Feed.should_receive(:fetch_and_parse).with('some_url').
                  and_return(stub(:entries => [entries_mock = stub(
                      :content => "I'm present, therefore I am!",
                      :author => "doesn't matter")]))
        entries_mock.should_not_receive(:content=)
        feed_source.entries
      end
    end
  end

  before :each do
    FeedSource.create! :url => 'http://a.com/feed', :feed_type => 'Blog'
  end
end

