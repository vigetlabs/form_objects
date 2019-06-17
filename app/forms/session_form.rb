class SessionForm
  include ActionForm::Form

  attributes :email, :password, from: :login

  validate :account_is_authentic, if: :credentials_supplied?

  def id
    existing_login&.id
  end

  def credentials_supplied?
    email.present? && password.present?
  end

  def existing_login
    @existing_login ||= Login.find_by(email: email)
  end

  private

  def account_is_authentic
    if !existing_login&.authenticate(password)
      errors.add(:email, "cannot be authenticated")
    end
  end
end
