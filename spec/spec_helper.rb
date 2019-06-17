ENV["APP_ENV"] ||= "test"

require "rspec"
require "rack/test"
require "capybara"
require "capybara/dsl"

require_relative "../config/application"
require_relative "../app"

Dir[ROOT.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.include(Shoulda::Matchers::ActiveModel, type: :form)
  config.include(Capybara::DSL, type: :system)

  config.before(:each, type: :system) do
    Capybara.configure do |config|
      config.app       = Application.new
      config.save_path = ROOT.join("tmp")
    end
  end

  config.before(:each) do
    ActiveRecord::Base.connection.begin_transaction
  end

  config.after(:each) do
    ActiveRecord::Base.connection.rollback_transaction
  end
end

RSpec::Matchers.define_negated_matcher(:not_change, :change)
