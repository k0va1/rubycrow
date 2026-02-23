module Admin
  class GithubRepoSearchesController < BaseController
    include ActionView::Helpers::NumberHelper

    def index
      if params[:id].present?
        repo = GithubRepo.find_by(id: params[:id])
        return render json: {error: "not found"}, status: :not_found unless repo
        render json: {id: repo.id, title: repo.full_name, url: repo.url, description: repo.description}
      elsif params[:q].present?
        repos = GithubRepo.search_by_name(params[:q]).recent(20)
        render json: repos.map { |r|
          {value: r.id, label: "#{r.full_name} (#{number_with_delimiter(r.stars)} stars)"}
        }
      else
        render json: []
      end
    end
  end
end
