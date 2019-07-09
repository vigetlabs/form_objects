# What is This?

This originated as an experiment to create a "form object" pattern that could
piggyback off of existing ActiveRecord validations, but ended up evolving into
two separate "projects":

1. `ActionForm` -- Create a "flat" form that is composed of multiple related
   components (e.g. `ActiveRecord` models, but any object that behaves like an
   `ActiveModel::Model` instance) that reuses validation and provides a central
   means of persistence.
1. `Sinatra::Form` -- Basic form helpers to use in Sinatra templates that
   function similarly to Rails's form helpers.

[Sinatra](http://sinatrarb.com/) was initially chosen for its simplicity and
to demonstrate functionality that can be used independently from Rails.

* [ActionForm](#actionform)
  * [Usage](#usage)
  * [Implementation](#implementation)
* [Sinatra::Form](#sinatra-form)
  * [Usage](#usage-1)
  * [Implementation](#implementation-1)

## ActionForm

Currently, ActionForm is designed to handle simple validations and basic
(create) persistence. Future implementations must allow for updating and
potentially deleting records atomically.

The following examples assume that these models, associations, and validations
exist in your application:

```ruby
class Login < ActiveRecord::Base
  validates :email, presence: true
end

class Person < ActiveRecord::Base
  has_one :login

  validates :first_name, :last_name, presence: true
end
```

### Usage

To get started, include the module in your form class:

```ruby
class AccountForm
  include ActionForm::Form
end
```

You can specify the attributes that you want to use from other models, which
will automatically include those validations:

```ruby
  attribute  :email, from: :login
  attributes :first_name, :last_name, from: :person
```

Since `ActionForm::Form` also includes `ActiveModel::Model`, attribute
assignment and validation works as expected:

```ruby
form = AccountForm.new(first_name: "Patrick")
form.valid? # => false

form.errors.full_messages # => ["Email can't be blank", "Last name can't be blank"]
```

The base module provides a `save` method that performs validations by default
but does not know how to handle persistence.  You must implement this in your
form class:

```ruby
  def save
    super do
      ActiveRecord::Base.transaction do
        person.login = login
        person.save!
      end
    end
  end
```

Because this class is an `ActiveModel::Model` at heart, you can also specify
additional attributes and validations as usual:

```ruby
  attr_accessor :hat_size
  validates :hat_size, numericality: true
```

See [`AccountForm`](app/forms/account_form.rb) in this project for a more
complete example.

### Implementation

The public interface of the form classes was designed to maintain consistency
with the `ActiveModel::Model` API -- `valid?` and `save` should function as
expected.

Additional implementation decisions include:

* Attributes that are referenced from other objects (e.g.
  `attribute :email, from: :login`) actually instantiate the underlying object
  (e.g. `Login.new(email: email)`) to avoid duplicate assignment during both
  validation and persistence.  These associated "components" are also made
  available via an expected accessor method (e.g. `form.login`).
* Individual components (e.g. `login`, `person`, etc ...) are validated in turn
  and resulting errors are copied to the errors collection on the form.
* In those cases where using the validations on a specific field is not desired,
  those errors are removed from the errors collection.

## Sinatra::Form

Due to a lack of viable options for generating forms inside of Sinatra views,
this library was an experiment to approximate the functionality of Rails's
`form_for` helper with some of the benefits of `simple_form`

### Usage

Usage in view templates should be pretty familiar:

```ruby
# views/accounts/new.erb
<% form_for AccountForm.new, "/accounts" do |f| %>
  <%= f.text_field :first_name, class: "form-field" %>
  <%= f.text_field :last_name, class: "form-field" %>
  <%= f.text_field :email, class: "form-field" %>
  <%= f.submit "Create Account" %>
<% end %>
```

The currently supported controls available at the form level are:

* `text_field`
* `password_field`
* `select`
* `submit`

Extending the available controls is a simple matter of using the available
building blocks and exposing them inside of the `Sinatra::Forms::Forms::Form`
class.

### Implementation

TODO
