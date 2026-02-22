module Admin
  class ArticleSearchesController < BaseController
    def index
      if params[:id].present?
        article = Article.includes(:blog).find(params[:id])
        render json: {id: article.id, title: article.title, url: article.url, description: article.summary}
      elsif params[:q].present?
        articles = Article.includes(:blog).search_by_title(params[:q]).recent(20)
        render json: articles.map { |a|
          {value: a.id, label: "#{a.title} — #{a.blog.name}"}
        }
      else
        render json: []
      end
    end
  end
end
