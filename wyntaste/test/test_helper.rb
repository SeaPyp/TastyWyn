ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "rantly"
require "rantly/shrinks"

# Rantly property_of helper — creates a Rantly generator that supports .check(n)
class RantlyProperty
  def initialize(&block)
    @block = block
  end

  def check(n = 100, &assertion)
    rantly = Rantly.new
    n.times do
      values = rantly.instance_eval(&@block)
      if values.is_a?(Array)
        assertion.call(*values)
      else
        assertion.call(values)
      end
    end
  end
end

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all

    def property_of(&block)
      RantlyProperty.new(&block)
    end
  end
end

module ActionDispatch
  class IntegrationTest
    def property_of(&block)
      RantlyProperty.new(&block)
    end

    # Helper to log in a user during integration tests
    def log_in_as(user, password: "password")
      post login_path, params: { email: user.email, password: password }
    end
  end
end
