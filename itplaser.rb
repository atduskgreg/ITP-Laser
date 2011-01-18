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
  # credential user: :login => params[:login], :password => params[:password]
  @job = WorkJob.create!(:created_at => Time.now, 
                         :nyu_login => params[:login], 
                         :description => params[:description])
  # DesignFile.upload_file(params[:data][:tempfile])
  # params[:data][:tempfile].path
  redirect '/laser/jobs' # TODO: no! users don't get sent here.
end

get "/laser/jobs" do
  @approved_jobs, @unapproved_jobs = WorkJob.all.partition{|j| j.approved?}
  erb :jobs
end

post "/laser/approve" do
  @job = WorkJob.get(params[:job_id])
  @job.approved = true
  @job.save!
  redirect "/laser/jobs"
end