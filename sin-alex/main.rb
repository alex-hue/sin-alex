require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/auth'
require 'slim'
require 'sass'
require 'sinatra/flash'
require 'pony'

require './song'
require './configTest'

configure do
  enable :sessions
  set :username, 'frank'
  set :password, 'sinatra'
end

helpers do
  def css(*stylesheets)
    stylesheets.map do |stylesheet|
      "<link href=\"/#{stylesheet}.css\" media=\"screen, projection\" rel=\"stylesheet\" />"
    end.join
  end
  def current?(path='/')
    (request.path==path || request.path==path+'/') ? "current" : nil
  end
  def send_message
    Pony.mail(
      :from => params[:name] + "<" + params[:email] + ">",
      :to => 'graffikkanv@gmail.com',
      :subject => params[:name] + " has contacted you",
      :body => params[:message],
      :port => '587',
      :via => :smtp,
      :via_options => {
        :address => 'smtp.gmail.com',
        :port => '587',
        :enable_starttls_auto => true,
        :user_name => 'graffikkanv@gmail.com',
        :password => 'Sander7661',
        :authentication => :plain,
        :domain => 'localhost.localdomain'
    })
  end

end

def set_title
  @title ||= "Songs By Sinatra"
end

before do
  set_title
end

get('/styles.css'){ scss :styles }

get '/' do
  @title = "Home of Sinatra"
  slim :home
end

get '/about' do
  @title = "All About This Website"
  slim :about
end

get '/contact' do
  @title = "Contact us"
  slim :contact
end

post '/contact' do
  send_message
  flash[:notice] = "Thank you for your message. We'll be in touch soon."
  redirect to('/')
end

not_found do
  @title = "Page Not Found"
  slim :not_found
end

get '/login' do
  slim :login
end

post '/login' do
  if params[:username] == settings.username && params[:password] == settings.password
    session[:admin] = true
    @loginname = params[:username]
    flash[:notice] = "LOGGED IN successfully"
    redirect to('/songs')
  else
    slim :login
  end
end

get '/logout' do
  session.clear
  flash[:notice] = "LOGGED OUT successfully"
  redirect to('/')
end
configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
  set :email_address => 'smtp.gmail.com',
    :email_user_name => 'daz',
    :email_password => 'secret',
    :email_domain => 'localhost.localdomain'
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
  set :email_address => 'smtp.sendgrid.net',
    :email_user_name => ENV['SENDGRID_USERNAME'],
    :email_password => ENV['SENDGRID_PASSWORD'],
    :email_domain => 'heroku.com'
end
