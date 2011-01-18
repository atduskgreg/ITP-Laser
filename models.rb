require 'dm-core'
require 'dm-migrations'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'mysql://localhost/itplaser')

class WorkJob
  include DataMapper::Resource   
  property :id,           Serial
  property :approved,     Boolean
  
  has n, :design_files
end

class DesignFile
  include DataMapper::Resource   
  property :id,           Serial
  
  belongs_to :work_job
  
  # PASSIVE MODE FTP FOR HEROKU:
  # ftp = Net::FTP.open("ftp.example.com") do |ftp|
  # ftp.login(user = "*****", passwd = "*****")
  # ftp.passive = true
  # ftp.putbinaryfile("public/data/myimage.jpg", File.basename( "myimage.jpg" ))
  # ftp.quit()
end