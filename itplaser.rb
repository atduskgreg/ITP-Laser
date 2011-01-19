require 'rubygems'
require 'sinatra'
require 'models'
require 'partials'

helpers Sinatra::Partials
set :views, File.dirname(__FILE__) + '/views'

get "/" do
  erb :home
end

get "/laser/new" do
  erb :new_laser
end

post "/laser" do
  job = WorkJob.create!(
    :created_at => Time.now, 
    :nyu_login => params[:login], 
    :description => params[:description])
  
  design_file = job.design_files.create!    
  design_file.upload!(params[:data][:tempfile], params[:data][:filename])
                     
  redirect "/laser/jobs/#{job.id}" # TODO: no! users don't get sent here.
end

get "/laser/jobs/:id" do
  @job = WorkJob.get params[:id]
  erb :job
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