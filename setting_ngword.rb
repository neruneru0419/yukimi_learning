#NGワード設定用のファイル

require 'pg'

class Ngword
  def initialize
    @ngwords = []
  end

  def connect_postgresql
    uri = URI.parse(ENV['DATABASE_URL'])
    @connect = PG.connect(uri.hostname, uri.port, nil, nil, uri.path[1..-1], uri.user, uri.password)
  end

  def close_postgresql
    @connect.finish
  end
=begin
  def insert_ngword
    File.open("setting.txt", "r") do |ngword|
      ngword.each_line do |n|
        @connect.exec("insert into ngwords VALUES ('#{n.chomp}')")    
      end
    end
  end
=end
  def show_ngword
    results = @connect.exec('select ngword from ngwords')
    results.each do |result|
      @ngwords.push(result['ngword'])
    end
    p @ngwords
  end

  def delete_ngword
    @connect.exec("delete from ngwords") 
  end

end

#main
ng = Ngword.new
ng.connect_postgresql
#ng.insert_ngword
ng.show_ngword
ng.close_postgresql