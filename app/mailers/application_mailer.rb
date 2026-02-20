class ApplicationMailer < ActionMailer::Base
  default from: "newsletter@mail.rubycrow.dev"
  layout "mailer"
end
