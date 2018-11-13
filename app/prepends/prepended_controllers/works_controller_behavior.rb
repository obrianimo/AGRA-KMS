# Based on the Module#prepend pattern in ruby which is used in some Hyrax.
# Uses the to_prepare Rails hook in application.rb to inject this module to override Hyrax::DownloadsController module
module PrependedControllers::WorksControllerBehavior
  
#   def set_title_sort(raw_params)
#     return unless raw_params.has_key? :title
#     the_title = raw_params[:title] 
#     return the_title    
#   end  

end
