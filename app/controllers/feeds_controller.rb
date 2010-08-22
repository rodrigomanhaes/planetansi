class FeedsController < ApplicationController
  def index
    render_feeds_for :blogs
  end

  def github
    render_feeds_for :githubs
  end

  private

  def render_feeds_for(type)
    @type = type == :blogs ? 'Textos e artigos dos membros do NSI' : 'Atividades dos membros do NSI no Github'
    @entries = FeedSource.send(type).
      map(&:entries).
      flatten.
      compact.
      sort_by(&:pubDate).
      reverse
    render :action => :index, :layout => false
    response.headers["Content-Type"] = "application/xml; charset=utf-8"
  end
end

