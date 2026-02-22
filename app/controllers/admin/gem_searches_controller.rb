module Admin
  class GemSearchesController < BaseController
    def index
      if params[:id].present?
        gem = RubyGem.find(params[:id])
        render json: {id: gem.id, name: gem.name, project_url: gem.project_url, info: gem.info}
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
