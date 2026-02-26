class ArticlesController < ApplicationController
  def index
    @articles = Article.includes(:blog).archived_last.by_publish_date.recent(15)
  end
end
