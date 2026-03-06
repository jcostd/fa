class LocationsController < ApplicationController
  def create
    @location = Location.new(location_params)

    if @location.save
      # Se ci è stato passato un return_to (es. /jobs/1/edit), ci accodiamo l'ID della nuova location.
      # Il redirect in Turbo 8 scatenerà un MORPH della pagina.
      if params[:return_to].present?
        redirect_to build_return_url(params[:return_to], @location.id)
      else
        redirect_to locations_path, notice: "Location creata."
      end
    else
      # Gestione errori standard
      redirect_to params[:return_to], alert: "Errore nella creazione della location."
    end
  end

  private
    def location_params
      params.require(:location).permit(:name, :district)
    end

    # Helper per aggiungere ?new_location_id=123 all'URL di ritorno
    def build_return_url(url, location_id)
      uri = URI.parse(url)
      query = Rack::Utils.parse_query(uri.query)
      query["new_location_id"] = location_id
      uri.query = Rack::Utils.build_query(query)
      uri.to_s
    end
end
