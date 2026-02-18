module Admin
  class TrackedLinksController < BaseController
    before_action :set_tracked_link, only: [:show, :edit, :update, :destroy]

    def index
      scope = TrackedLink.includes(:newsletter_issue, :article).order(created_at: :desc)
      scope = scope.where(newsletter_issue_id: params[:newsletter_issue_id]) if params[:newsletter_issue_id].present?
      @pagy, @tracked_links = pagy(scope)
    end

    def show
    end

    def new
      @tracked_link = TrackedLink.new
    end

    def create
      @tracked_link = TrackedLink.new(tracked_link_params)

      if @tracked_link.save
        redirect_to admin_tracked_link_path(@tracked_link), notice: "Tracked link created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @tracked_link.update(tracked_link_params)
        redirect_to admin_tracked_link_path(@tracked_link), notice: "Tracked link updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @tracked_link.destroy
      redirect_to admin_tracked_links_path, notice: "Tracked link deleted."
    end

    private

    def set_tracked_link
      @tracked_link = TrackedLink.find(params[:id])
    end

    def tracked_link_params
      params.require(:tracked_link).permit(:destination_url, :newsletter_issue_id, :article_id, :section, :position_in_newsletter)
    end
  end
end
