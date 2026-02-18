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
    end

    def create
      @newsletter_issue = NewsletterIssue.new(newsletter_issue_params)

      if @newsletter_issue.save
        redirect_to admin_newsletter_issue_path(@newsletter_issue), notice: "Newsletter issue created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @newsletter_issue.update(newsletter_issue_params)
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
      params.require(:newsletter_issue).permit(:issue_number, :subject, :sent_at, :subscriber_count, :total_clicks, :total_unique_clicks)
    end
  end
end
