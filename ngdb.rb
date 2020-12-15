require "pg"

connect = PG.connect(:user => "env", :password => "env")

results = connect.exec("insert * from test")

results.each{|result|
  p result
}

connect.finish