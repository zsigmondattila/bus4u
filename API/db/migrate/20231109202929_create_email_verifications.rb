class CreateEmailVerifications < ActiveRecord::Migration[7.0]
  def change
    create_table :email_verifications do |t|
      t.string :email
      t.string :verification_code

      t.timestamps
    end
  end
end
