Rails.application.routes.draw do

  mount ManybotsGmail::Engine => "/manybots-gmail"
end
