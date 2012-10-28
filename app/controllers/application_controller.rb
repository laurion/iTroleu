class ApplicationController < ActionController::Base
  protect_from_forgery

  has_mobile_fu(true)
  before_filter :set_default_response_format

  protected

    def set_default_response_format
      request.format = 'mobile'.to_sym if params[:format].nil?
    end
end
