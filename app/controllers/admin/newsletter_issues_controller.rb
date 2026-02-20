module Admin
  class NewsletterIssuesController < BaseController
    before_action :set_newsletter_issue, only: [:show, :edit, :update, :destroy]

    def index
      @pagy, @newsletter_issues = pagy(NewsletterIssue.order(created_at: :desc))
    end

    def show
    end

    def new
      @newsletter_issue = NewsletterIssue.new
      NewsletterSection::DEFAULT_SECTIONS.each_with_index do |section, index|
        @newsletter_issue.newsletter_sections.build(
          title: section.humanize.titleize,
          position: index
        )
      end
    end

    def create
      @newsletter_issue = NewsletterIssue.new(newsletter_issue_params)

      if @newsletter_issue.save
        @newsletter_issue.create_tracked_links!
        redirect_to admin_newsletter_issue_path(@newsletter_issue), notice: "Newsletter issue created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @newsletter_issue.update(newsletter_issue_params)
        @newsletter_issue.create_tracked_links!
        redirect_to admin_newsletter_issue_path(@newsletter_issue), notice: "Newsletter issue updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @newsletter_issue.destroy
      redirect_to admin_newsletter_issues_path, notice: "Newsletter issue deleted."
    end

    private

    def set_newsletter_issue
      @newsletter_issue = NewsletterIssue.find(params[:id])
    end

    def newsletter_issue_params
      params.require(:newsletter_issue).permit(
        :issue_number, :subject, :sent_at, :subscriber_count, :total_clicks, :total_unique_clicks,
        newsletter_sections_attributes: [
          :id, :title, :position, :_destroy,
          newsletter_items_attributes: [:id, :title, :description, :url, :position, :article_id, :_destroy]
        ]
      )
    end
  end
end
