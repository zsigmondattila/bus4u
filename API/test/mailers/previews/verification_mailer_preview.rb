# Preview all emails at http://localhost:3000/rails/mailers/verification_mailer
class VerificationMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/verification_mailer/verificaton_mailer
  def verification_mailer
    VerificationMailer.verification_mailer("alma","0122")
  end

end
