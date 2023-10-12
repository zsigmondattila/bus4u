class V1::ApplicationController < ApplicationController

    def hello
        render json: {welcome: "Szerusz"}
    end
end
