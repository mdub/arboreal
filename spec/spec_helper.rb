$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require "active_record"
require "logger"
require "fileutils"

FileUtils.mkdir_p("tmp")
ActiveRecord::Base.logger = Logger.new("tmp/test.log")
ActiveRecord::Base.logger.level = Logger::DEBUG

ActiveRecord::Schema.verbose = false

DB_CONFIGS = {
  "sqlite3" => {
    :database => 'tmp/test.sqlite'
  },
  "mysql" => {
    :host     => 'localhost',
    :database => 'weblog_development',
    :username => 'blog',
    :password => ''
  },
  "postgresql" => {
    :host     => 'localhost',
    :database => 'weblog_development',
  },
  "jdbcmssql" => {
    :host     => 'localhost',
    :port     => 1433,
    :database => 'weblog_development',
    :username => 'blog',
    :password => ''
  }
}

test_adapter = (ENV["AR_ADAPTER"] || "sqlite3")
test_db_config = DB_CONFIGS[test_adapter].merge(:adapter => test_adapter)

ActiveRecord::Base.establish_connection(test_db_config)
