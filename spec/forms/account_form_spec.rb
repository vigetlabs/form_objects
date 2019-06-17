require "spec_helper"

RSpec.describe AccountForm, type: :form do
  required_attributes = [
    :first_name,
    :last_name,
    :email,
    :password,
    :street_1,
    :city,
    :state_id,
    :postal_code
  ]

  required_attributes.each do |attribute_name|
    it { should validate_presence_of(attribute_name) }
  end

  it { should validate_confirmation_of(:password) }

  [:person, :address, :login].each do |composition_name|
    describe "##{composition_name}" do
      it "has an associated object" do
        klass = composition_name.to_s.classify.constantize
        expect(subject.send(composition_name)).to be_instance_of(klass)
      end

      it "is unpersisted by default" do
        expect(subject.send(composition_name)).to_not be_persisted
      end
    end
  end

  x = {
    person:  [:first_name, :last_name],
    login:   [:email, :password, :password_confirmation],
    address: [:street_1, :street_2, :city, :state_id, :postal_code]
  }

  x.each do |composition_name, attribute_names|
    attribute_names.each do |attribute_name|
      describe "#{attribute_name}=" do
        let(:value) { attribute_name.to_s.end_with?("_id") ? 1 : "string" }

        it "sets the value of #{attribute_name}" do
          expect { subject.send("#{attribute_name}=", value) }.to \
            change { subject.send(attribute_name) }.from(nil).to(value)
        end

        it "sets the value of #{composition_name}.#{attribute_name}" do
          expect { subject.send("#{attribute_name}=", value) }.to \
            change { subject.send(composition_name).send(attribute_name) }.from(nil).to(value)
        end
      end
    end
  end

  describe "#save" do
    context "when invalid" do
      it "does not persist data" do
        expect { subject.save }.to \
          not_change { Person.count }.and \
          not_change { Login.count }.and \
          not_change { Address.count }
      end

      it "returns false" do
        expect(subject.save).to be(false)
      end
    end

    context "when valid" do
      let(:state) { State.find_by!(abbreviation: "CO") }

      subject do
        described_class.new({
          first_name:            "Patrick",
          last_name:             "Reagan",
          email:                 "user@host.com",
          password:              "password",
          password_confirmation: "password",
          street_1:              "12 Main Street",
          city:                  "Anytown",
          state_id:              state.id,
          postal_code:           "12345"
        })
      end

      it "persists data" do
        expect { subject.save }.to \
          change { Person.count }.and \
          change { Login.count }.and \
          change { Address.count }
      end

      it "returns true" do
        expect(subject.save).to be(true)
      end
    end
  end
end
