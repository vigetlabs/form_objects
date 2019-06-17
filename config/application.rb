ENV["APP_ENV"] ||= "development"

require "pathname"
require "logger"
require "bundler"

Bundler.setup(:default, ENV["APP_ENV"])

require "active_record"

ROOT = Pathname.new(__FILE__).join("..", "..").expand_path

$:.unshift(ROOT.join("app"), ROOT.join("lib"))

require "action_form"

require "models/address"
require "models/login"
require "models/person"
require "models/state"

require "forms/account_form"
require "forms/session_form"

ActiveRecord::Base.logger = Logger.new(ROOT.join("log", %{#{ENV["APP_ENV"]}.log}))

ActiveRecord::Base.establish_connection({
  adapter:  "sqlite3",
  database: ROOT.join("db", %{#{ENV["APP_ENV"]}.sqlite3})
})

sql = ROOT.join("db", "schema.sql").read

statements = sql.split(/;$/).map(&:strip).reject(&:blank?)
statements.each {|s| ActiveRecord::Base.connection.execute(s) }
