require "bundler"

Bundler.setup(:default)

require_relative "config/application"

require "sinatra/base"
require "sinatra/forms"

class Application < Sinatra::Base
  enable :sessions

  include Sinatra::Forms::TagHelper
  include Sinatra::Forms::FormHelper

  get "/" do
    view("accounts/new", locals: {
      account_form: AccountForm.new,
      states:       State.all
    })
  end

  get "/login" do
    view("sessions/new", locals: {session_form: SessionForm.new})
  end

  post "/login" do
    session_form = SessionForm.new(params)

    if session_form.valid?
      self.current_login = session_form.existing_login
      redirect to("/account")
    else
      view("sessions/new", locals: {session_form: session_form})
    end
  end

  post "/accounts" do
    account_form = AccountForm.new(params)

    if account_form.save
      self.current_login = account_form.login
      redirect to("/account")
    else
      view("accounts/new", locals: {
        account_form: account_form,
        states:       State.all
      })
    end
  end

  get "/account" do
    redirect to("/") and return unless current_login.present?

    view("accounts/show", locals: {login: current_login})
  end

  private

  def default_layout
    :"layouts/application"
  end

  def view(view_file, locals: {}, layout: nil)
    erb(view_file.to_sym, {
      layout: (layout || default_layout),
      locals: locals
    })
  end

  def current_login=(login)
    session[:current_login_id] = login&.id
  end

  def current_login
    @current_login ||= Login.find_by(id: session[:current_login_id])
  end

  def logout
    self.current_login = nil
  end
end
