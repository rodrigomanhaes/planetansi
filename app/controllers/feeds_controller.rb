class FeedsController < ApplicationController
  def index
    blogs
  end

  def blogs
    render_feeds_for :blogs
  end

  def githubs
    render_feeds_for :githubs
  end

  private

  def render_feeds_for(type)
    @entries = FeedSource.send(type)
    @subtitle = type == :blogs ? 'Textos e artigos dos membros do NSI' : 'Atividades dos membros do NSI no Github'
    render :action => :index, :layout => false
    response.headers["Content-Type"] = "application/xml; charset=utf-8"
  end
end

