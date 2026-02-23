module Admin
  class RedditPostsController < BaseController
    include PeriodFilterable

    before_action :set_reddit_post, only: [:show, :edit, :update, :destroy]

    def index
      scope = RedditPost.by_post_date
      scope = scope.from_subreddit(params[:subreddit]) if params[:subreddit].present?

      @period = params[:period]
      scope = scope.where("posted_at >= ?", PERIOD_FILTERS[@period].ago) if PERIOD_FILTERS.key?(@period)

      @search = params[:search]
      scope = scope.search_by_title(@search) if @search.present?

      @pagy, @reddit_posts = pagy(scope)
    end

    def show
    end

    def new
      @reddit_post = RedditPost.new
    end

    def create
      @reddit_post = RedditPost.new(reddit_post_params)

      if @reddit_post.save
        redirect_to admin_reddit_post_path(@reddit_post), notice: "Reddit post created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @reddit_post.update(reddit_post_params)
        redirect_to admin_reddit_post_path(@reddit_post), notice: "Reddit post updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @reddit_post.destroy
      redirect_to admin_reddit_posts_path, notice: "Reddit post deleted."
    end

    private

    def set_reddit_post
      @reddit_post = RedditPost.find(params[:id])
    end

    def reddit_post_params
      params.require(:reddit_post).permit(:reddit_id, :title, :url, :external_url, :score, :author, :subreddit, :num_comments, :posted_at, :processed, :featured_in_issue)
    end
  end
end
