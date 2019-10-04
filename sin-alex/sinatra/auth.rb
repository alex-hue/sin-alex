require 'sinatra/base'
require 'sinatra/flash'

module Sinatra
  module Auth
    module Helpers
      def authorized?
        session[:admin]
      end

      def protected!
        halt 401, slim( :unauthorized) unless authorized?
      end
    end

    def self.registere(app)
      app.helpers Helper

      app.enable :sessions

      app.set :username => 'frank',
              :password => 'sinatra'

      app.get '/login' do
        slim :slim
      end

      app.post '/login' do
        if params[ :username] == settings.username && params[ :password] == settings.password
          session[ :admin] = true
          flash[ :notice] = "You are now logged in as #{settings.username}"
          redirect to('/songs')
        else
          flash[ :notice] = "The username or password you entered are incorrect"
          redirect to('login')
        end
      end

      app.get '/logou' do
        session[ :admin] = nil
        flash[ :notice] = "You have now logged out"
        redirect to('/')
      end
    end
  end
  register Auth

end
