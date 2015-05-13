require 'bundler'
Bundler.require

DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://db/main.db')
require './models.rb'

use Rack::Session::Cookie, :key => 'rack.session',
    :expire_after => 2629743.833333,
    :secret => SecureRandom.hex(64)

get '/' do
  if session[:uid]
    @users = User.all
    @topics = Topic.all

    @u = User.first(:id => session[:uid])

    erb :userhome
  else

    erb :index
  end
end

get '/signup' do

  erb :signup
end

post '/user/create' do
  if params[:confirm] == params[:password]
    u = User.new
    u.username = params[:username]
    u.password = params[:password]
    u.save

    redirect '/'
  else

    erb :signup
  end
end

post '/user/:id/delete' do
  u = User.where(:id => params[:id])
  u.destroy

  redirect '/'
end

post '/user/login' do
  u = User.first(:username => params[:username])

  if params[:pass] == u.password
    session[:uid] = u.id
    redirect '/'
  end
end

post '/topic/create' do
  t = Topic.new
  t.name = params[:topic]
  t.id = params[:id]
  t.save

  redirect '/'
end

get '/topic/:id' do
  @t = Topic.first(:id => params[:id])
  @posts = @t.posts

  erb :thread_display
end

post '/topic/:id/delete' do
  t = Topic.where(:id => params[:id])
  t.destroy

  redirect '/'
end

post '/topic/:tid/post/create' do
  u = User.first(:id => session[:uid])
  t = Topic.first(:id => params[:tid])

  p = Post.new
  p.content = params[:content]
  p.topic = t
  p.user = u
  p.save
  redirect '/topic/' + t.id.to_s
end
