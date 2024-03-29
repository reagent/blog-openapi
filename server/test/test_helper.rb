ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods

    make_my_diffs_pretty!

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)
  end
end
