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
  
  def authenticate_or_redirect(opts)
    unless NYUser.authenticate(params[:login], params[:password])
      flash[:error] =  "Bad credentials."
      redirect opts[:to]
    end
  end
  
  get "/" do
    erb :home
  end
  
  get "/laser/new" do
    erb :new_laser
  end
  
  post "/laser" do
    authenticate_or_redirect(:to => "/laser/new")
    
    job = WorkJob.create!(
      :created_at => Time.now, 
      :nyu_login => params[:login], 
      :description => params[:description])
    
    design_file = job.design_files.create!    
    design_file.upload!(params[:data][:tempfile], params[:data][:filename])
                       
    redirect "/laser/jobs/#{job.id}"
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
end