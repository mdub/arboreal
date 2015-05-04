$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require "active_record"
require "logger"
require "fileutils"

FileUtils.mkdir_p("tmp")
ActiveRecord::Base.logger = Logger.new("tmp/test.log")
ActiveRecord::Base.logger.level = Logger::DEBUG

require_relative "support/db"
require "arboreal"
require_relative "support/node"

RSpec.configure do |c|
  c.before(:each) do
    Node::Migration.up
  end

  c.after(:each) do
    Node::Migration.down
  end
end
