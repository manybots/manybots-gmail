require "manybots_gmail/engine"

module ManybotsGmail
  
  # Gmail App Id for Imap/XOAuth. Defaults to anonymous
  mattr_accessor :gmail_app_id
  @@gmail_app_id = 'anonymous'

  # Gmail App Secret for Imap/XOAuth. Defaults to anonymous
  mattr_accessor :gmail_app_secret
  @@gmail_app_secret = 'anonymous'
  
  mattr_accessor :app
  @@app = nil
  
  mattr_accessor :nickname
  @@nickname = nil
  
  
  def self.setup
    yield self
  end
  
end
