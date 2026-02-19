module Admin
  class ArticlesController < BaseController
    before_action :set_article, only: [:show, :edit, :update, :destroy]

    PERIOD_FILTERS = {
      "last_week" => 1.week,
      "last_2_weeks" => 2.weeks,
      "last_month" => 1.month
    }.freeze

    def index
      scope = Article.includes(:blog)
      scope = scope.where(blog_id: params[:blog_id]) if params[:blog_id].present?

      @period = params[:period]
      scope = scope.where("published_at >= ?", PERIOD_FILTERS[@period].ago) if PERIOD_FILTERS.key?(@period)

      @pagy, @articles = pagy(scope)
    end

    def show
    end

    def new
      @article = Article.new
    end

    def create
      @article = Article.new(article_params)

      if @article.save
        redirect_to admin_article_path(@article), notice: "Article created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @article.update(article_params)
        redirect_to admin_article_path(@article), notice: "Article updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @article.destroy
      redirect_to admin_articles_path, notice: "Article deleted."
    end

    private

    def set_article
      @article = Article.find(params[:id])
    end

    def article_params
      params.require(:article).permit(:title, :url, :blog_id, :content_snippet, :summary, :published_at, :processed, :featured_in_issue)
    end
  end
end
