class GmailWorker
  require 'gmail'
  @queue = :observers
  
  def self.perform(gmail_account_id, date_range='recent')
    
    current_app = ManybotsGmail.app  
    gmail_account = OauthAccount.find(gmail_account_id)
    
    user_id = gmail_account.user_id
    address = gmail_account.remote_account_id
    
    mailbox = gmail_account.payload[:mailbox].present? ? gmail_account.payload[:mailbox] : '[Gmail]/All Mail'
    
    user = User.find(user_id)
    
    if date_range == 'recent'
      the_date = ManybotsGmail::Email.where(:user_id => user_id, :address => address).latest.first
      if the_date
        the_date = the_date.sent_at.to_date - 2.days
      else
        the_date = Date.today - 5.days
      end
    else
      the_date = Date.new
    end

    gmail = GmailWorker.imap_client(gmail_account)
    begin
      emails = gmail.mailbox(mailbox).emails(:after => the_date)
    rescue => e
      raise "Error connecting to gmail Connection error:" + e.inspect
    end
    emails.each do |email|
      envelope = email.envelope
      unless ManybotsGmail::Email.exists?(:user_id => user_id, :muid => email.uid, :address => gmail_account.remote_account_id)
        mail = ManybotsGmail::Email.new
        mail.user_id = user_id
        mail.muid = email.uid
        mail.address = gmail_account.remote_account_id
        
        mail.subject = envelope.subject
        mail.sent_at = email.date
        mail.tags = email.labels.collect(&:to_s)

        mail.from = envelope.from.collect do |sender|
          {:name => sender.name, :email =>"#{sender.mailbox}@#{sender.host}"}
        end if envelope.from

        mail.to = envelope.to.collect do |sender|
          {:name => sender.name, :email =>"#{sender.mailbox}@#{sender.host}"}
        end if envelope.to

        mail.cc = envelope.cc.collect do |sender|
          {:name => sender.name, :email =>"#{sender.mailbox}@#{sender.host}"}
        end if envelope.cc

        mail.bcc = envelope.bcc.collect do |sender|
          {:name => sender.name, :email =>"#{sender.mailbox}@#{sender.host}"}
        end if envelope.bcc
        
        mail.save
        mail.post_to_manybots!
      end
    end if emails and emails.any?
  
    gmail.logout
  end
  
  def self.imap_client(gmail_account)
    Gmail.connect(:xoauth, gmail_account.remote_account_id,
      :consumer_key => ManybotsGmail.gmail_app_id,
      :consumer_secret => ManybotsGmail.gmail_app_secret,
      :token => gmail_account.token,
      :secret => gmail_account.secret
    )
  end
  
  
end


