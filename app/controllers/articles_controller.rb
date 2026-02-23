class ArticlesController < ApplicationController
  def index
    @articles = Article.includes(:blog).by_publish_date.recent(15)
  end
end
