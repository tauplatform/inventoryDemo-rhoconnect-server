class ApplicationController < Rhoconnect::Controller::AppBase
  register Rhoconnect::EndPoint

  post "/login", :rc_handler => :authenticate,
                 :deprecated_route => {:verb => :post, :url => ['/application/clientlogin', '/api/application/clientlogin']} do
    login = params[:login]
    password = params[:password]

    puts "login auth: #{@auth_token}"

    return @auth_token=='ifoundit'
  end

  get "/rps_login", :rc_handler => :rps_authenticate, 
                    :login_required => true do
    login = params[:login]
    password = params[:password]
    true # optionally handle rhoconnect push authentication...
  end
end
