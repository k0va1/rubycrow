class RedirectsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def show
    tracked_link = TrackedLink.select(:id, :destination_url).find_by(token: params[:token])

    unless tracked_link
      redirect_to root_path
      return
    end

    RecordClickJob.perform_later(
      tracked_link_id: tracked_link.id,
      subscriber_id: params[:sid],
      user_agent: request.user_agent,
      ip_address: request.remote_ip,
      clicked_at: Time.current.iso8601
    )

    redirect_to tracked_link.destination_url, allow_other_host: true
  end
end
