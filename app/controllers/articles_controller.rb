class ArticlesController < ApplicationController
  def index
    @articles = Article.includes(:blog).recent(15)
  end
end
