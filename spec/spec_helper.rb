require 'spec'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require "rubygems"

require "active_record"

ActiveRecord::Schema.verbose = false

Spec::Runner.configure do |config|

  config.before(:all) do
    ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3', 
    :database => 'spec/test.sqlite'
    )
  end

  config.after(:all) do
    ActiveRecord::Base.clear_active_connections!
  end

end
