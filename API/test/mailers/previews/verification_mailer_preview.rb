# Preview all emails at http://localhost:3000/rails/mailers/verification_mailer
class VerificationMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/verification_mailer/verificaton_mailer
  def verificaton_mailer
    VerificationMailer.verificaton_mailer
  end

end
