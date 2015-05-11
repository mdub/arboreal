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
