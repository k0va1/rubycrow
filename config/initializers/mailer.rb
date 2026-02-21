if Rails.env.production?
  Resend.api_key = Rails.application.credentials.resend_api_key

  ActionMailer::MailDeliveryJob.retry_on(
    Resend::Error::RateLimitExceededError,
    wait: :polynomially_longer,
    attempts: 30
  )
end
