FactoryBot.define do
  factory :login do
    person

    sequence(:email) {|n| "user-#{n}@host.example" }

    password              { "password" }
    password_confirmation { password }
  end
end
