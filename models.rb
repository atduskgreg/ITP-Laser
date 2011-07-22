require 'dm-core'
require 'dm-migrations'
require 'net/sftp'
require 'net/http'

FTP_URL = "itp.nyu.edu"
FTP_PATH = "/some/path"
FTP_USER = "your username"
FTP_PASSWORD = "your password"

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'mysql://localhost/itplaser')

FTP_URL = "itp.nyu.edu"
FTP_PATH = "/something"
FTP_USER = "you"
FTP_PASSWORD = "your password"

class NYUser
  LDAP_PROXY = 'http://itp.nyu.edu/~cmk380/ldap_proxy/'
  
  def self.authenticate(user, pass)
    res = Net::HTTP.post_form(URI.parse(LDAP_PROXY), {'username'=>user, 'password'=>pass})
    res.body == "true"
  end
  
  def jobs
    @jobs ||= WorkJobs.all
  end
  
  def approved_jobs
    @jobs.select{|j| j.approved?}
  end
  
  def unapproved_jobs
    @jobs.select{|j| !j.approved?}
  end
end

class WorkJob
  include DataMapper::Resource   
  property :id,           Serial
  property :approved,     Boolean
  property :completed,    Boolean
  property :nyu_login,    String
  property :description,  String
  property :created_at,   DateTime  
  
  has n, :design_files
  
  def status
    self.approved? ? "approved" : "pending"
  end
  
  def resubmit
    self.approved = false
    self.completed = false
    self.save
  end
end

class DesignFile
  include DataMapper::Resource   
  property :id,           Serial
  property :filename,     String  
  belongs_to :work_job
  

  def upload!(tmp, orig_filename)
    self.filename = "#{work_job.nyu_login}_#{orig_filename}"
    DesignFile.upload_file(tmp, self.filename)
    self.save!
  end
  
  def url
    "http://itp.nyu.edu/~gab305/lasertest/#{filename}"
  end
  
  def self.upload_file(tmp, filename)
    Net::SFTP.start(FTP_URL, FTP_USER, :password => FTP_PASSWORD) do |sftp|
      sftp.upload!(tmp.path, "#{FTP_PATH}/#{filename}")
    end
     # PASSIVE MODE FTP FOR HEROKU:
    # ftp = Net::FTP.open("itp.nyu.edu") do |ftp|
    #      ftp.login(user = "gab305", passwd = "!Poa20876")
    #      ftp.passive = true
    #      ftp.puttextfile(tmp.path, File.basename( "test.ai" ))
    #      ftp.quit
    # end
  end
  
end