module ManybotsGmail
  class Email < ActiveRecord::Base
    store :people, :accessors => [:to, :from, :cc, :bcc]
    
    belongs_to :user
    
    scope :latest, lambda {
      order('manybots_gmail_emails.created_at DESC')
    }
    

    def owner_is
      email = self.address
      if self.from.collect {|f| true if f[:email].match(email.to_s) }.include?(true) 
        return "sender"
      elsif self.to and self.to.collect {|f| true if f[:email].match(email.to_s) }.include?(true) 
        return "to"
      elsif self.cc and self.cc.collect {|f| true if f[:email].match(email.to_s) }.include?(true) 
        return "cc"
      elsif self.bcc and self.bcc.collect {|f| true if f[:email].match(email.to_s) }.include?(true) 
        return "bcc"
      else
        return "unlisted"
      end
    end
    
    def decoded(field)
      decode_str self.send(field)
    end

    def activity_sentence
      return case owner_is
        when "sender"
         "ACTOR sent an OBJECT to TARGET"
        when "to"
         "ACTOR received an OBJECT from TARGET"
        when "cc"
         "ACTOR was Cc:ed in an OBJECT from TARGET"
        when "bcc"
         "ACTOR was Bcc:ed in an OBJECT from TARGET"
        else
         "ACTOR received an OBJECT from TARGET"
      end
    end

    def activity_target
       if self.owner_is == "sender"
         [self.to, self.cc, self.bcc].flatten.compact
       else
         self.from
       end
    end
    
    def as_activity
      activity = {
          # PROPERTIES
          :id => "#{ManybotsServer.url}/manybots-gmail/emails/#{self.id}/activity",
          :url => "#{ManybotsServer.url}/manybots-gmail/emails/#{self.id}/activity",
          :title => self.activity_sentence + ' - ' + decode_str(self.subject).to_s,
          :auto_title => true,
          :summary => nil,
          :content => nil,
          :published => self.sent_at.xmlschema,
          :icon => {
            :url => 'http://mail.google.com/mail/images/2/mail_icon_32.png'
          },
          :provider => {
            :displayName => 'Gmail',
            :url => 'http://mail.google.com',
            :image => {
              :url => 'http://mail.google.com/mail/images/2/mail_icon_32.png'
            }
          },
          :generator => {
            :displayName => 'Gmail Observer',
            :url => "#{ManybotsServer.url}/manybots-gmail",
            :image => {
              :url => "#{ManybotsServer.url}/assets/manybots-gmail/icon.png"
            }
          },
          # VERB
          :verb => (self.owner_is == 'sender' ? 'send' : 'receive'),
          # TAGS
          :tags => self.tags.present? ? YAML::load(self.tags.to_s) : [],
          # ACTOR
          :actor => {
            :displayName => self.address,
            :id => "#{ManybotsServer.url}/users/#{self.user_id}",
            :url => "#{ManybotsServer.url}/users/#{self.user_id}",
            :email => self.address
          },
          # OBJECT
          :object => {
            :displayName => "Email",
            :id => "#{ManybotsServer.url}/manybots-gmail/emails/#{self.id}",
            :url => "#{ManybotsServer.url}/manybots-gmail/emails/#{self.id}",
            :objectType => 'email'
          }
      }

      if self.activity_target.length <= 1
        activity[:target] = {
            :displayName => decode_str(self.activity_target.first[:name]) || self.activity_target.first[:email],
            :id => "#{ManybotsServer.url}/manybots-gmail/people/#{CGI.escape self.activity_target.first[:email]}",
            :url => "#{ManybotsServer.url}/manybots-gmail/people/#{CGI.escape self.activity_target.first[:email]}",
            :objectType => 'person',
            :email => self.activity_target.first[:email]
          } if self.activity_target.any?
      else
        activity[:target] = {
          :displayName => "#{activity_target.length} people",
          :id => "#{ManybotsServer.url}/manybots-gmail/emails/#{self.id}/people",
          :url => "#{ManybotsServer.url}/manybots-gmail/emails/#{self.id}/people",
          :objectType => 'group',
          :attachments => activity_target.collect { |to| 
            {
              :displayName => decode_str(to[:name]) || to[:email], 
              :objectType => 'person',
              :email => to[:email],
              :id => "#{ManybotsServer.url}/manybots-gmail/people/#{CGI.escape to[:email]}",
              :url => "#{ManybotsServer.url}/manybots-gmail/people/#{CGI.escape to[:email]}"
            } 
          }
        }
      end
      
      activity
    end

    def post_to_manybots!
      RestClient.post("#{ManybotsServer.url}/activities.json", 
        {
          :activity => self.as_activity, 
          :client_application_id => ManybotsGmail.app.id,
          :version => '1.0', 
          :auth_token => self.user.authentication_token
        }.to_json, 
        :content_type => :json, 
        :accept => :json
      )
    end

     protected 
     
     def decode_str(str)
       if str.is_a?(String) and str.match 'ISO-8859-1'
         begin
           Mail::SubjectField.new(str).decoded 
          rescue => e
            puts e
          end
       else
         str
       end
     end

     def truncate(text, length = 140, end_string = ' ...')
       words = text.split()
       words[0..(length-1)].join(' ') + (words.length > length ? end_string : '')
     end
  end
end
