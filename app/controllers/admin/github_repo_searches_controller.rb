module Admin
  class GithubRepoSearchesController < BaseController
    def index
      if params[:id].present?
        repo = GithubRepo.find(params[:id])
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

    private

    def number_with_delimiter(number)
      ActiveSupport::NumberHelper.number_to_delimited(number)
    end
  end
end
