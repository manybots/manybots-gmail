module ManybotsGmail
  class EmailsController < ::ApplicationController
    before_filter :authenticate_user!
    
    def show
      @email = ManybotsGmail::Email.find_by_id_and_user_id(params[:id], current_user.id)
    end
    
    def from_gmail
      @email = ManybotsGmail::Email.find_by_id_and_user_id(params[:id], current_user.id)
      @message = @email.body      
    end
    
  end
end
