class StationsController < ApplicationController
  def index
    @stations = Station.all
    
    respond_to do |format|
      format.xml {render xml: @stations}
    end
  end
end
