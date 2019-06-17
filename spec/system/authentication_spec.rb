require "spec_helper"

RSpec.describe "Authentication", type: :system do
  it "redirects unauthenticated users" do
    visit "/account"
    expect(page).to have_current_path("/")
  end

  it "rejects invalid logins" do
    visit "/login"

    fill_in "Email",    with: "user@host.example"
    fill_in "Password", with: "password"

    click_on "Log In"

    expect(page).to have_current_path("/login")
    expect(page).to have_error_on("Email", "cannot be authenticated")
  end

  it "allows login" do
    person = create(:person, first_name: "Patrick", last_name: "Reagan")

    login = create(:login, {
      person:   person,
      email:    "user@host.example",
      password: "password"
    })

    visit "/login"

    fill_in "Email", with: "user@host.example"
    fill_in "Password", with: "password"

    click_on "Log In"

    expect(page).to have_current_path("/account")
    expect(page).to have_content("Patrick Reagan")
  end
end
