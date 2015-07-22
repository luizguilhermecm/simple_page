#!/usr/bin/env ruby
# encoding: UTF-8

require 'pg'

require './tables'
require './passwds'

def db_exists
    db_name = settings.dbname
    db_owner = settings.user
    puts "checking if database '#{db_name}' exists"
    c = PGconn.connect(:user=>DB_ADMIN_USER, :dbname=>DB_ADMIN_DB, :password => DB_ADMIN_PASSWD)
    r = c.exec("SELECT COUNT(*) FROM pg_database WHERE datname='#{db_name}'")
    if r.entries[0]['count'].to_i == 1
        puts "database '#{db_name}' exists"
        puts "dropping database '#{db_name}' ... "
        drop_db_sql = ""
        drop_db_sql = " DROP DATABASE #{db_name}"
        if db_name == "xururub"
            r = c.exec(drop_db_sql)
        else
            puts "Error: Cowardly refusing to `#{drop_db_sql}`"
        end
    else
        puts "database '#{db_name}' do not exists"
        puts "creating database '#{db_name}' ... "
        create_db_sql = " -- SQL \n"
        create_db_sql += " CREATE DATABASE #{db_name} \n"
        create_db_sql += " WITH OWNER = #{db_owner} \n"
        create_db_sql += "      ENCODING = 'UTF8' \n"
        create_db_sql += "      TABLESPACE = pg_default \n"
        create_db_sql += "      LC_COLLATE = 'en_US.UTF-8' \n"
        create_db_sql += "      LC_CTYPE = 'en_US.UTF-8' \n"
        create_db_sql += "      CONNECTION LIMIT = -1; \n"
        create_db_sql += " -- SQL \n"
        puts create_db_sql
        begin
            r = c.exec(create_db_sql)
            puts "database '#{db_name}' created ... "
        rescue Exception => e
            puts "[ FAIL ] an error occurred while database '#{db_name}' was being created "
            puts e
        end
        puts "checking if database '#{db_name}' was successfully created ..."
        c = PGconn.connect(:user=>DB_ADMIN_USER, :dbname=>DB_ADMIN_DB, :password => DB_ADMIN_PASSWD)
        r = c.exec("SELECT COUNT(*) FROM pg_database WHERE datname='#{db_name}'")
        if r.entries[0]['count'].to_i == 1
            puts "[ OK ] database '#{db_name}' was successfully created ..."
        else
            puts "[ FAIL ] something happened, database '#{db_name}' was not created ..."
            puts "[ INFO ] run to the hills"
            puts "[ INFO ] shutting down"

            return false
        end
    end
    return true
end
def get_check_table_sql(tb_name)
    check_table_sql = ""
    check_table_sql += " \n -- SQL \n"
    check_table_sql += " SELECT EXISTS ( \n"
    check_table_sql += "   SELECT 1 \n"
    check_table_sql += "   FROM   information_schema.tables \n"
    check_table_sql += "   WHERE 1 = 1 \n"
    check_table_sql += "   AND table_name = '#{tb_name}' \n"
    check_table_sql += " ); \n"
    check_table_sql += " -- SQL \n"

    return check_table_sql
end

def checking_tables(conn, tb_name, tb_name_sql)
    query = get_check_table_sql(tb_name)
    puts "checking if table '#{tb_name}' do exist "
    r = conn.exec(query)
    if r.entries[0]['exists'].to_s == "t"
        puts "table '#{tb_name}' do exist "
    else
        puts "table '#{tb_name}' do not exists "
        puts "creating table '#{tb_name}' ... "
        r = conn.exec(tb_name_sql)
    end
end

class SimplePage < Sinatra::Base
  set :host, DB_HOST
  set :dbname, DB_NAME
  set :user, DB_SYS_USER
  set :password, DB_SYS_PASSWD
  #set :bind, '0.0.0.0'
  set :environment, :production

  if db_exists
      @@conn = PG.connect(:host => settings.host, :dbname => settings.dbname, :user => settings.user, :password => settings.password)
      puts "start to checking tables"
      puts "table : #{TB_TESTE_NAME}"
      checking_tables(@@conn, TB_TESTE_NAME, TB_TESTE_SQL)
  else
      @@conn = nil
  end

  configure :production, :test do
    enable :logging
    use Rack::Session::Pool
    set :erb, :trim => '-'
  end

  not_found do
    'Página não encontrada!'
  end

  get '/' do
     if @@conn == nil
         erb :index
     else
         erb :xururu
     end
  end

  get '/insert' do
      text = params[:text]

      @@conn.exec_params(' INSERT INTO teste(id, nome) VALUES($1, $2) ',
                       [432, text.to_s])

      ret = @@conn.exec_params(' SELECT * FROM teste WHERE id = $1 ',
                       [432])

      puts "++++++++++++++++++++++++++++++++++++++++"
      puts text
      puts "++++++++++++++++++++++++++++++++++++++++"
      ret.each do |x|
          puts x
      end
      puts "++++++++++++++++++++++++++++++++++++++++"
     erb :index
  end

  run! if app_file == $0
end
