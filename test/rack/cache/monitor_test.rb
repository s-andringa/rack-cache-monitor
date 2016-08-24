require 'test_helper'
require 'logger'

class Rack::Cache::MonitorTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Rack::Cache::Monitor::VERSION
  end
end
