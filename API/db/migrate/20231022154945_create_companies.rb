class CreateCompanies < ActiveRecord::Migration[7.0]
  def change
    create_table :companies, id: false do |t|
      t.string :company_uid, primary_key: true
      t.string :name
      t.string :email
      t.string :phone_number
      t.string :tax_number
      t.string :city
      t.string :office_address

      t.timestamps
    end
  end
end
