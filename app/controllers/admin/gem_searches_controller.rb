module Admin
  class GemSearchesController < BaseController
    def index
      if params[:id].present?
        gem = RubyGem.find_by(id: params[:id])
        return render json: {error: "not found"}, status: :not_found unless gem
        render json: {id: gem.id, title: gem.name, url: gem.project_url, description: gem.info}
      elsif params[:q].present?
        gems = RubyGem.search_by_name(params[:q]).recent(20)
        render json: gems.map { |g|
          {value: g.id, label: "#{g.name} (#{g.version})"}
        }
      else
        render json: []
      end
    end
  end
end
