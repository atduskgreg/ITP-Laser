require 'rubygems'
require 'sinatra'
require 'models'

set :views, File.dirname(__FILE__) + '/views'

get "/" do
  erb :home
end

get "/laser/new" do
  erb :new_laser
end

post "/laser" do
  params[:data][:tempfile].inspect
end