class SubscribersController < ApplicationController
  rate_limit to: 5, within: 1.minute, only: :create, with: -> {
    @form_id = params[:form_id] || "subscribe-form"
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(@form_id, partial: "subscribers/form", locals: {error: "Too many attempts. Please try again later.", form_id: @form_id}), status: :too_many_requests
      }
    end
  }

  def create
    @subscriber = Subscriber.new(email: params[:email])
    @form_id = params[:form_id] || "subscribe-form"

    if @subscriber.save
      SubscriberMailer.confirmation(subscriber: @subscriber).deliver_later
      respond_to do |format|
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@form_id, partial: "subscribers/form", locals: {error: @subscriber.errors.full_messages.first, form_id: @form_id}), status: :unprocessable_content }
      end
    end
  end
end
