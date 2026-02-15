class SubscribersController < ApplicationController
  def create
    @subscriber = Subscriber.new(email: params[:email])
    @form_id = params[:form_id] || "subscribe-form"

    if @subscriber.save
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
