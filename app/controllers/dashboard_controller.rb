class DashboardController < ApplicationController
  def start
  end

  def destination
    session[:start_coords] = {:long => params[:long], :lat => params[:lat]}
  end

  def search
  end
end
