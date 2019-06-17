RSpec::Matchers.define(:have_error_on) do |label_name, error_message|
  match do |page|
    parent_of(page, label_name)&.has_text?(error_message)
  end

  failure_message do
    "Expected field '#{label_name}' to have error message '#{error_message}'"
  end

  match_when_negated do |page|
    !parent_of(page, label_name)&.has_css?(%{.invalid-feedback})
  end

  failure_message_when_negated do
    "Expected field '#{label_name}' to have no errors"
  end

  private

  def parent_of(page, label_name)
    page.first(:label, text: label_name)&.first(:xpath, ".//..")
  end
end
