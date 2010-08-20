class FeedsController < ApplicationController
  def index
    @entries = Blog.all.
      map(&:entries).
      flatten.
      compact.
      sort_by(&:pubDate).
      reverse
    render :layout => false
    response.headers["Content-Type"] = "application/xml; charset=utf-8"
  end
end

