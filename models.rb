require 'dm-core'
require 'dm-migrations'
require 'net/ftp'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'mysql://localhost/itplaser')

class WorkJob
  include DataMapper::Resource   
  property :id,           Serial
  property :approved,     Boolean
  property :nyu_login,    String
  property :description,  String
  property :created_at,   DateTime  
  
  has n, :design_files
end

class DesignFile
  include DataMapper::Resource   
  property :id,           Serial
  
  belongs_to :work_job
  
  def self.upload_file(tmp)
     # PASSIVE MODE FTP FOR HEROKU:
    ftp = Net::FTP.open("itp.nyu.edu") do |ftp|
      ftp.login(user = "gab305", passwd = "!Poa20876")
      ftp.passive = true
      ftp.puttextfile(tmp.path, File.basename( "test.ai" ))
      ftp.quit
    end
  end
  
end