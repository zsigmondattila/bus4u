require "test_helper"

class VerificationMailerTest < ActionMailer::TestCase
  test "verificaton_mailer" do
    mail = VerificationMailer.verificaton_mailer
    assert_equal "Verificaton mailer", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
