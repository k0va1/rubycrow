module Admin
  class ClicksController < BaseController
    before_action :set_click, only: [:show, :destroy]

    def index
      scope = Click.includes(:tracked_link, :subscriber).order(clicked_at: :desc)
      scope = scope.where(tracked_link_id: params[:tracked_link_id]) if params[:tracked_link_id].present?
      scope = scope.where(subscriber_id: params[:subscriber_id]) if params[:subscriber_id].present?
      @pagy, @clicks = pagy(scope)
    end

    def show
    end

    def destroy
      @click.destroy
      redirect_to admin_clicks_path, notice: "Click deleted."
    end

    private

    def set_click
      @click = Click.find(params[:id])
    end
  end
end
