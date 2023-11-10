class VerificationMailer < ApplicationMailer
  def verification_mailer(email, code)
      @verification_code = code
      @email = email
      mail(to: @email , subject: 'Your verification code from Bus4U')
  end
end