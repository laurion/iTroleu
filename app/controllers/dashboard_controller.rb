class DashboardController < ApplicationController
  def start
    session[:start_coords] = {} if session[:start_coords].nil?
    session[:end_coords] = {} if session[:end_coords].nil?
  end

  def destination
    session[:start_coords] = params[:pos] if params[:pos]
  end

  def search
    session[:start_coords] = {} if session[:start_coords].nil?
    session[:end_coords] = params[:pos] if params[:pos]
  end
end
