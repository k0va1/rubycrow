module Admin
  class RedditPostSearchesController < BaseController
    def index
      if params[:id].present?
        post = RedditPost.find(params[:id])
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
