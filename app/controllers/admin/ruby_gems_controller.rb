module Admin
  class RubyGemsController < BaseController
    include PeriodFilterable

    before_action :set_ruby_gem, only: [:show, :edit, :update, :destroy]

    def index
      scope = RubyGem.by_version_date
      scope = scope.where(activity_type: params[:activity_type]) if params[:activity_type].present?

      @period = params[:period]
      scope = scope.where("version_created_at >= ?", PERIOD_FILTERS[@period].ago) if PERIOD_FILTERS.key?(@period)

      @search = params[:search]
      scope = scope.search_by_name(@search) if @search.present?

      @pagy, @ruby_gems = pagy(scope)
    end

    def show
    end

    def new
      @ruby_gem = RubyGem.new
    end

    def create
      @ruby_gem = RubyGem.new(ruby_gem_params)

      if @ruby_gem.save
        redirect_to admin_ruby_gem_path(@ruby_gem), notice: "Gem created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @ruby_gem.update(ruby_gem_params)
        redirect_to admin_ruby_gem_path(@ruby_gem), notice: "Gem updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @ruby_gem.destroy
      redirect_to admin_ruby_gems_path, notice: "Gem deleted."
    end

    private

    def set_ruby_gem
      @ruby_gem = RubyGem.find(params[:id])
    end

    def ruby_gem_params
      params.require(:ruby_gem).permit(:name, :version, :authors, :info, :downloads, :project_url, :homepage_url, :source_code_url, :version_created_at, :activity_type, :processed, :featured_in_issue)
    end
  end
end
