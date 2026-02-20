class ConfirmationsController < ApplicationController
  def show
    subscriber = Subscriber.find_signed(params[:signed_id], purpose: :confirmation)

    if subscriber
      subscriber.update!(confirmed: true)
      render inline: confirmed_html, layout: false, content_type: "text/html"
    else
      redirect_to root_path
    end
  end

  private

  def confirmed_html
    <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Confirmed — RubyCrow</title>
        <style>
          body { background: #0a0a0a; color: #f0f0f0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif; display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; }
          .card { text-align: center; max-width: 400px; padding: 48px 32px; }
          h1 { font-size: 24px; margin: 0 0 12px; }
          p { color: #888; font-size: 15px; line-height: 1.5; margin: 0; }
        </style>
      </head>
      <body>
        <div class="card">
          <h1>You're confirmed!</h1>
          <p>Welcome to the flock. You'll receive the next issue of RubyCrow in your inbox.</p>
        </div>
      </body>
      </html>
    HTML
  end
end
