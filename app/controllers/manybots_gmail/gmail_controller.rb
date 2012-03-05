module ManybotsGmail
  class GmailController < ApplicationController
    before_filter :authenticate_user!
    layout 'shared/application'

    def index
      @gmails = current_user.oauth_accounts.where(:client_application_id => current_app.id)
      @schedules = ManybotsServer.queue.get_schedules
    end

    def new
      consumer = get_consumer

      request_token = consumer.get_request_token({ :oauth_callback => callback_gmail_index_url }, { :scope => 'https://mail.google.com/ https://www.googleapis.com/auth/userinfo#email' })
      session[:gmail_token] = request_token.secret
      redirect_to request_token.authorize_url
    end

    def show
    end
    
    def import
      gmail = current_user.oauth_accounts.find(params[:id])
      
      schedule_name = "import_manybots_gmail_emails_#{gmail.id}"
      schedules = ManybotsServer.queue.get_schedules
      
      if schedules and schedules.keys.include?("import_manybots_gmail_emails_#{gmail.id}")
        ManybotsServer.queue.remove_schedule schedule_name
        gmail.status = 'off'
      else 
        gmail.payload[:mailbox] = params[:gmail][:mailbox] if params[:gmail][:mailbox].present?
        gmail.status = 'on'

        ManybotsServer.queue.add_schedule schedule_name, {
          :every => '30m',
          :class => "GmailWorker",
          :queue => "observers",
          :args => [gmail.id, :recent],
          :description => "This job will import emails every 30 minutes for OauthAccount ##{gmail.id}"
        }
        if ManybotsGmail::Email.exists?(:user_id => current_user.id, :address => gmail.remote_account_id)
          ManybotsServer.queue.enqueue(GmailWorker, gmail.id, :recent)
        else
          ManybotsServer.queue.enqueue(GmailWorker, gmail.id, :history)
        end
      end
      gmail.save
      
      redirect_to root_path
    end

    def callback
      consumer = get_consumer

      token = OAuth::RequestToken.new(consumer, params[:oauth_token], session[:gmail_token])
      access_token = token.get_access_token({:oauth_verifier => params[:oauth_verifier]})

      profile_params = access_token.get('https://www.googleapis.com/userinfo/email').body
      profile = Rack::Utils.parse_query(profile_params).with_indifferent_access

      gmail = current_user.oauth_accounts.find_or_create_by_client_application_id_and_remote_account_id(current_app.id, profile[:email])
      gmail.update_attributes({
         :token => access_token.token,
         :secret => access_token.secret
      })

      redirect_to gmail_index_path
    end

    def list_folders
      gmail_account = current_user.oauth_accounts.find(params[:id])
    
      gmail = GmailWorker.imap_client(gmail_account)
      @folders = gmail.labels.all
      gmail.logout
    
      render :layout => false
    end

    def destroy
      gmail = current_user.oauth_accounts.find(params[:id])
      schedule_name = "import_manybots_gmail_emails_#{gmail.id}"
      ManybotsServer.queue.remove_schedule schedule_name
      gmail.destroy
      ManybotsGmail::Email.where(:user_id => current_user.id, :address => gmail.remote_account_id).destroy_all
      redirect_to gmail_index_path
    end

    private
    
    def current_app
      @manybots_gmail_app ||= ManybotsGmail.app
    end
    
    def get_consumer
      @consumer ||= OAuth::Consumer.new(ManybotsGmail.gmail_app_id, ManybotsGmail.gmail_app_secret, {
        :site => "https://www.google.com",
        :request_token_path => "/accounts/OAuthGetRequestToken",
        :access_token_path => "/accounts/OAuthGetAccessToken",
        :authorize_path => "/accounts/OAuthAuthorizeToken"
      })
    end
    
  end
end
