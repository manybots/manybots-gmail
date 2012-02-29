class GmailToManybotsWorker
  @queue = :importers
  
  def self.perform(email_id)
    email = ManybotsGmail::Email.find(email_id)
    email.post_to_manybots!
  end

end