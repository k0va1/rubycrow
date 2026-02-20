module Admin
  class NewsletterIssuesController < BaseController
    before_action :set_newsletter_issue, only: [:show, :edit, :update, :destroy, :preview, :publish]

    def index
      @pagy, @newsletter_issues = pagy(NewsletterIssue.order(created_at: :desc))
    end

    def show
    end

    def new
      next_issue_number = (NewsletterIssue.maximum(:issue_number) || 0) + 1
      @newsletter_issue = NewsletterIssue.new(issue_number: next_issue_number)
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

    def preview
      subscriber = Subscriber.first || Subscriber.new(id: 0, email: "preview@example.com")
      mail = NewsletterMailer.issue(newsletter_issue: @newsletter_issue, subscriber: subscriber)
      html_part = mail.html_part.body.decoded
      render html: html_part.html_safe, layout: false
    end

    def publish
      if @newsletter_issue.sent_at.present?
        redirect_to admin_newsletter_issue_path(@newsletter_issue), alert: "This issue has already been published."
        return
      end

      SendNewsletterJob.perform_later(newsletter_issue_id: @newsletter_issue.id)
      redirect_to admin_newsletter_issue_path(@newsletter_issue), notice: "Newsletter is being sent to all subscribers."
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
