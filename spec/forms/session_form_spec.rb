require "spec_helper"

RSpec.describe SessionForm, type: :form do
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }

  describe "#id" do
    it "is nil by default" do
      expect(subject.id).to be_nil
    end

    it "returns the login id when there are valid credentials" do
      login = create(:login, email: "user@host.example", password: "password")

      subject = described_class.new({
        email:    "user@host.example",
        password: "password"
      })

      expect(subject.id).to eq(login.id)
    end
  end

  describe "#valid?" do
    it "is false when there are no logins" do
      subject = described_class.new({
        email:    "user@host.example",
        password: "password"
      })

      expect(subject).to_not be_valid
      expect(subject.errors[:email]).to eq(["cannot be authenticated"])
    end

    it "is false when the password does not match the email" do
      create(:login, email: "user@host.example", password: "password")

      subject = described_class.new({
        email:    "user@host.example",
        password: "invalid"
      })

      expect(subject).to_not be_valid
      expect(subject.errors[:email]).to eq(["cannot be authenticated"])
    end

    it "is true when the credentials are valid" do
      create(:login, email: "user@host.example", password: "password")

      subject = described_class.new({
        email:    "user@host.example",
        password: "password"
      })

      expect(subject).to be_valid
      expect(subject.errors).to be_empty
    end
  end
end
