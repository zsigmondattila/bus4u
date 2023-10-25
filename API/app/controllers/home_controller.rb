class HomeController < ApplicationController
  def index
    send_file Rails.root.join('app', 'views', 'home', 'api.jpg'), type: 'image/jpg', disposition: 'inline'
  end
end
