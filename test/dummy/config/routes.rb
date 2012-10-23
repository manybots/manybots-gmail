Rails.application.routes.draw do

  mount ManybotsGmail::Engine => "/manybots_gmail"
end
