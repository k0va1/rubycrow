class ApplicationMailer < ActionMailer::Base
  default from: "newsletter@rubycrow.dev"
  layout "mailer"
end
