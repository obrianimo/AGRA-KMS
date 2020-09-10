# Based on the Module#prepend pattern in ruby which is used in some Hyrax.
# Uses the to_prepare Rails hook in application.rb to inject this module to override Hyrax::DownloadsController module
module PrependedControllers::CollectionsController
  
  def create
    params[:collection]["title_sort"] = params[:collection]["title"][0] if params[:collection]["title"].present? 
    super
  end

  def update
    params[:collection]["title_sort"] = params[:collection]["title"][0] if params[:collection]["title"].present? 
    super
  end

end
