class AccountForm
  include ActionForm::Form

  delegate :id, to: :login

  attributes :first_name, :last_name, from: :person
  attributes :email, :password, :password_confirmation, from: :login
  attributes :street_1, :street_2, :city, :state_id, :postal_code, from: :address

  def save
    super do
      ActiveRecord::Base.transaction do
        person.login   = login
        person.address = address
        person.save!
      end
    end
  end
end
