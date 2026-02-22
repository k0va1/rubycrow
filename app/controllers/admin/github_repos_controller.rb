module Admin
  class GithubReposController < BaseController
    before_action :set_github_repo, only: [:show, :edit, :update, :destroy]

    PERIOD_FILTERS = {
      "last_week" => 1.week,
      "last_2_weeks" => 2.weeks,
      "last_month" => 1.month
    }.freeze

    def index
      scope = GithubRepo.all

      @period = params[:period]
      scope = scope.where("repo_pushed_at >= ?", PERIOD_FILTERS[@period].ago) if PERIOD_FILTERS.key?(@period)

      @search = params[:search]
      scope = scope.search_by_name(@search) if @search.present?

      @pagy, @github_repos = pagy(scope)
    end

    def show
    end

    def new
      @github_repo = GithubRepo.new
    end

    def create
      @github_repo = GithubRepo.new(github_repo_params)

      if @github_repo.save
        redirect_to admin_github_repo_path(@github_repo), notice: "GitHub repo created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @github_repo.update(github_repo_params)
        redirect_to admin_github_repo_path(@github_repo), notice: "GitHub repo updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @github_repo.destroy
      redirect_to admin_github_repos_path, notice: "GitHub repo deleted."
    end

    private

    def set_github_repo
      @github_repo = GithubRepo.find(params[:id])
    end

    def github_repo_params
      params.require(:github_repo).permit(:full_name, :name, :description, :url, :stars, :forks, :language, :owner_name, :owner_avatar_url, :repo_created_at, :repo_pushed_at, :processed, :featured_in_issue, topics: [])
    end
  end
end
