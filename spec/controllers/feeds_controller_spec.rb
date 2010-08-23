require 'spec_helper'
require 'feed_validator'

describe FeedsController do
  context 'common behavior' do
    feed_types = [:blogs, :githubs]

    it 'sets content-type to application/xml and utf-8 charset' do
      feed_types.each do |feed_type|
        FeedSource.stub(feed_type)
        get feed_type
        response.headers['Content-Type'].should == 'application/xml; charset=utf-8'
      end
    end

    it 'renders index' do
      feed_types.each do |feed_type|
        FeedSource.stub(feed_type)
        get feed_type
        response.should render_template 'index'
      end
    end

    it 'renders without layout' do
      feed_types.each do |feed_type|
        FeedSource.stub(feed_type)
        get feed_type
        # someone knows how to do it? the form below was removed
        # template.expect_render :layout => false
      end
    end
  end

  context 'index' do
    it 'assigns @subtitle for blog feeds' do
      get :index
      assigns[:subtitle].should == 'Textos e artigos dos membros do NSI'
    end

    it 'retrieves blog entries from FeedSource and assign them to @entries' do
      FeedSource.should_receive(:blogs).and_return(blogs_stub = stub)
      get :index
      assigns[:entries].should == blogs_stub
    end
  end

  context 'github' do
    it 'assigns @subtitle for github feeds' do
      get :githubs
      assigns[:subtitle].should == 'Atividades dos membros do NSI no Github'
    end

    it 'retrieves github entries from FeedSource and assign them to @entries' do
      FeedSource.should_receive(:githubs).and_return(githubs_stub = stub)
      get :githubs
      assigns[:entries].should == githubs_stub
    end
  end
end

