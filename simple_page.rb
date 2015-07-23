#!/usr/bin/env ruby
# encoding: UTF-8

require 'pg'
require 'sinatra'

require './tables'
require './passwds'

class SimplePage < Sinatra::Base
  set :host, DB_HOST
  set :dbname, DB_NAME
  set :user, DB_SYS_USER
  set :password, DB_SYS_PASSWD
  set :bind, '0.0.0.0:4569'
  set :environment, :production

  @@conn = PG.connect(:host => settings.host, :dbname => settings.dbname, :user => settings.user, :password => settings.password)

  configure :production, :test do
    enable :logging
    use Rack::Session::Pool
    set :erb, :trim => '-'
  end

  not_found do
    'Página não encontrada!'
  end

  get '/' do
         erb :index
  end

  get '/insert' do
      text = params[:text]

      if text[0..2] == 'cat'
          ret = @@conn.exec('SELECT nome FROM teste')

          puts "++++++++++++++++++++++++++++++++++++++++"
          @ret = []
          ret.each do |x|
              @ret << {
                :nome => x["nome"],
              }
              puts x
          end
          puts "++++++++++++++++++++++++++++++++++++++++"
          erb :xururu
      else
          @@conn.exec_params(' INSERT INTO teste(nome) VALUES($1) ', [text.to_s])
          erb :xururu
      end
  end

  get "/passwd" do
      @@pass = params[:pass]
      puts "**************************************************"
      puts "* login with pass:    " + @@pass
      puts "**************************************************"
      if @@pass == "xxx"
          erb :xururu
      else
          erb :index
      end
  end

  get "/renderizar_admin/" do
      puts "**************************************************"
      puts "**************************************************"
      puts "**************************************************"
      puts "**************************************************"
      puts "**************************************************"
      puts "**************************************************"
      puts "**************************************************"
      erb :xururu
  end
  get '/insertX' do
      text = params[:text]

      if text[0..2] == 'snk'
          text = text.gsub(/snk/, '')
          @@conn.exec_params(' INSERT INTO teste(nome) VALUES($1) ', [text.to_s])

          erb :xururu
      elsif text[0..2] == 'cat'
          ret = @@conn.exec('SELECT nome FROM teste')

          puts "++++++++++++++++++++++++++++++++++++++++"
          @ret = []
          ret.each do |x|
              @ret << {
                :nome => x["nome"],
              }
              puts x
          end
          puts "++++++++++++++++++++++++++++++++++++++++"
          erb :xururu
      else
          erb :index
      end
  end

  run! if app_file == $0
end
