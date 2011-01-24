require 'rubygems'
require 'sinatra/base'
require 'models'
require 'partials'
require 'rack-flash'



class ITPLaser < Sinatra::Base
  helpers Sinatra::Partials
  use Rack::Flash
  
  enable :sessions
  set :views, File.dirname(__FILE__) + '/views'
  
  class NoWayJose < Exception; end

  def authenticate_or_redirect(opts)
    if NYUser.authenticate(params[:login], params[:password])
      return true
    else
      flash[:error] = "Bad password or username."
      redirect opts[:to]
    end
  end
  
  get "/" do
    erb :home
  end
  
  get "/laser/new" do
    erb :new_laser
  end
  
  get "/user/:login/jobs" do
    @jobs = WorkJob.all(:nyu_login => params[:login])
    @approved_jobs, @unapproved_jobs = @jobs.partition{|j| j.approved?}
    erb :user_jobs
  end
  
  post "/laser" do
    authenticate_or_redirect(:to => "/laser/new")

    job = WorkJob.create!(
      :created_at => Time.now, 
      :nyu_login => params[:login], 
      :description => params[:description])
    
    design_file = job.design_files.create!    
    design_file.upload!(params[:data][:tempfile], params[:data][:filename])
                       
    redirect "/jobs/#{job.id}"
  end
  
  get "/jobs/:id" do
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
end