module Admin
  class RedditPostSearchesController < BaseController
    def index
      if params[:id].present?
        post = RedditPost.find_by(id: params[:id])
        return render json: {error: "not found"}, status: :not_found unless post
        render json: {id: post.id, title: post.title, url: post.url, description: "r/#{post.subreddit} by #{post.author}"}
      elsif params[:q].present?
        posts = RedditPost.search_by_title(params[:q]).recent(20)
        render json: posts.map { |p|
          {value: p.id, label: "#{p.title} (r/#{p.subreddit})"}
        }
      else
        render json: []
      end
    end
  end
end
