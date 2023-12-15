class ApplicationController < ActionController::API
        before_action :configure_permitted_parameters, if: :devise_controller?
        include DeviseTokenAuth::Concerns::SetUserByToken

        protected

        def configure_permitted_parameters
                devise_parameter_sanitizer.permit(:sign_up, keys: [:company_uid, :firstname, :lastname, :role, :phone_number, :address])
        end
end
