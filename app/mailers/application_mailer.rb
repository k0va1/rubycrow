class ApplicationMailer < ActionMailer::Base
  default from: "RubyCrow <newsletter@mail.rubycrow.dev>"
  layout "mailer"
end
