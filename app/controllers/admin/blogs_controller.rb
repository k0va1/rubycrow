module Admin
  class BlogsController < BaseController
    before_action :set_blog, only: [:show, :edit, :update, :destroy]

    def index
      @pagy, @blogs = pagy(Blog.order(created_at: :desc))
    end

    def show
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
