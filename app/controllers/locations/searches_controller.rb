class Locations::SearchesController < ApplicationController
  def index
    @locations = params[:query].present? ? Location.search_text(params[:query]).limit(10) : Location.none

    render partial: "locations/searches/results", locals: { locations: @locations }, layout: false
  end
end
