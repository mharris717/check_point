

require 'rubygems'
require 'spork'

Spork.prefork do
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
  $LOAD_PATH.unshift(File.dirname(__FILE__))

  require 'rspec'

  load File.dirname(__FILE__) + "/../lib/check_point.rb"

  # Load support files
  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

  RSpec.configure do |config|
    config.fail_fast = true
  end
end

Spork.each_run do
  CheckPoint.load!
end


