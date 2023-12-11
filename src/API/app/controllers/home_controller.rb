class HomeController < ApplicationController
  def index
    send_file Rails.root.join('app', 'views', 'home', 'logo-api.svg'), type: 'image/svg+xml', disposition: 'inline'
  end
end