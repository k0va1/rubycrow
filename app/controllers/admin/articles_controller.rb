module Admin
  class ArticlesController < BaseController
    include PeriodFilterable

    before_action :set_article, only: [:show, :edit, :update, :destroy, :archive, :unarchive]

    def index
      scope = Article.includes(:blog).archived_last.by_publish_date
      scope = scope.where(blog_id: params[:blog_id]) if params[:blog_id].present?

      @period = params[:period]
      scope = scope.where("published_at >= ?", PERIOD_FILTERS[@period].ago) if PERIOD_FILTERS.key?(@period)

      @search = params[:search]
      scope = scope.search_by_title(@search) if @search.present?

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

    def archive
      @article.archive!
      redirect_to admin_article_path(@article), notice: "Article archived."
    end

    def unarchive
      @article.unarchive!
      redirect_to admin_article_path(@article), notice: "Article unarchived."
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
      params.require(:article).permit(:title, :url, :blog_id, :summary, :published_at, :processed, :featured_in_issue)
    end
  end
end
