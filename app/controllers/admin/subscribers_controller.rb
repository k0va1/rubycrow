module Admin
  class SubscribersController < BaseController
    before_action :set_subscriber, only: [:show, :edit, :update, :destroy]

    def index
      @pagy, @subscribers = pagy(Subscriber.order(created_at: :desc))
    end

    def show
    end

    def new
      @subscriber = Subscriber.new
    end

    def create
      @subscriber = Subscriber.new(subscriber_params)

      if @subscriber.save
        redirect_to admin_subscriber_path(@subscriber), notice: "Subscriber created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @subscriber.update(subscriber_params)
        redirect_to admin_subscriber_path(@subscriber), notice: "Subscriber updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @subscriber.destroy
      redirect_to admin_subscribers_path, notice: "Subscriber deleted."
    end

    private

    def set_subscriber
      @subscriber = Subscriber.find(params[:id])
    end

    def subscriber_params
      params.require(:subscriber).permit(:email, :confirmed, :subscribed_at, :unsubscribed_at)
    end
  end
end
