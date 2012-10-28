class DashboardController < ApplicationController
  def start
  end

  def destination
    session[:start_coords] = params[:pos]
  end

  def search
    session[:end_coords] = params[:pos]
  end
end
