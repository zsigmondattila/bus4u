class EmailVerification < ApplicationRecord
    before_create :generate_verification_code

    private
    def generate_verification_code
        self.verification_code = rand(1000..9999).to_s
    end
end
