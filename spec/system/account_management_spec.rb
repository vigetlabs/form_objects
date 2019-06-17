require "spec_helper"

RSpec.describe "Managing accounts", type: :system do
  describe "account creation" do
    it "displays errors when invalid" do
      visit "/"

      fill_in "First Name", with: "Patrick"

      expect { click_on "Submit" }.to \
        not_change { Person.count }.and \
        not_change { Address.count }.and \
        not_change { Login.count }

      expect(page).to have_current_path("/accounts")

      expect(page).to_not have_error_on("First Name")
      expect(page).to     have_error_on("Last Name", "can't be blank")
    end

    it "creates an account and redirects to account detail page" do
      visit "/"

      fill_in "First Name",       with: "Patrick"
      fill_in "Last Name",        with: "Reagan"
      fill_in "Email",            with: "patrick.reagan@viget.com"
      fill_in "Password",         with: "password"
      fill_in "Confirm Password", with: "password"
      fill_in "Street 1",         with: "12 Main Street"
      fill_in "City",             with: "Anytown"
      fill_in "Postal Code",      with: "12345"

      select "CO", from: "State"

      expect { click_on "Submit" }.to \
        change { Person.count }.by(1).and \
        change { Address.count }.by(1).and \
        change { Login.count }.by(1)

      expect(page).to have_current_path("/account")

      expect(page).to have_content("Patrick Reagan")
    end
  end
end
