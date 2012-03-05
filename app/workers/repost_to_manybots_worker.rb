class RepostToManybotsWorker
  @queue = :importers

  def self.perform(user_id)
    ManybotsGmail::Email.where(:user_id => user_id).find_each do |email|
      begin
        email.post_to_manybots!
      rescue => e
        puts e
      end
    end
  end
end