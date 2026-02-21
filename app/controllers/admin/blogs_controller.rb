module Admin
  class BlogsController < BaseController
    before_action :set_blog, only: [:show, :edit, :update, :destroy]

    PERIOD_FILTERS = {
      "last_week" => 1.week,
      "last_2_weeks" => 2.weeks,
      "last_month" => 1.month
    }.freeze

    def index
      blogs = Blog
        .left_joins(:articles)
        .select("blogs.*, MAX(articles.published_at) AS latest_article_at")
        .group("blogs.id")
        .order(Arel.sql("MAX(articles.published_at) DESC NULLS LAST"))

      @period = params[:period]
      if PERIOD_FILTERS.key?(@period)
        blogs = blogs.having("MAX(articles.published_at) >= ?", PERIOD_FILTERS[@period].ago)
      end

      @search = params[:search]
      if @search.present?
        term = "%#{Blog.sanitize_sql_like(@search)}%"
        blogs = blogs.where("blogs.name ILIKE :term OR blogs.url ILIKE :term", term: term)
      end

      @pagy, @blogs = pagy(blogs)
    end

    def show
      @recent_articles = @blog.articles.order(published_at: :desc).limit(20)
    end

    def new
      @blog = Blog.new
    end

    def create
      @blog = Blog.new(blog_params)

      if @blog.save
        redirect_to admin_blog_path(@blog), notice: "Blog created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @blog.update(blog_params)
        redirect_to admin_blog_path(@blog), notice: "Blog updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @blog.destroy
      redirect_to admin_blogs_path, notice: "Blog deleted."
    end

    private

    def set_blog
      @blog = Blog.find(params[:id])
    end

    def blog_params
      permitted = params.require(:blog).permit(:name, :url, :rss_url, :description, :twitter, :active, :tags_string)
      if permitted[:tags_string]
        permitted[:tags] = permitted.delete(:tags_string).split(",").map(&:strip).compact_blank
      end
      permitted
    end
  end
end
