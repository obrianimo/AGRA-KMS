# Based on the Module#prepend pattern in ruby which is used in some Hyrax.
# Uses the to_prepare Rails hook in application.rb to inject this module to override Hyrax::DownloadsController module
module PrependedControllers::WorksControllerBehavior
  
  def show
    super
    update_public_usage_stats
  end

  def update_public_usage_stats
    @curation_concern = _curation_concern_type.find(params[:id]) unless curation_concern
    if updateUsageStatsCheck(params[:id])
      @usage_stats = PublicUsageStats.find_or_initialize_by(:file_id => @curation_concern.id)
      if @usage_stats.title.present?
        @usage_stats.update(:last_viewed_at => Time.current, :views => @usage_stats.views + 1)
      else
        @usage_stats.title = @curation_concern.title[0].to_s
        @usage_stats.last_viewed_at = Time.current
        @usage_stats.views = 1
        @usage_stats.downloads = 0
        @usage_stats.created_at = Time.current
        @usage_stats.save
      end
      (session[:viewed_doc_ids] ||= []) << params[:id]
    end
   end

   def updateUsageStatsCheck(doc_id)
     # if the request isn't using the form, it's a bot, return false
       if session[:viewed_doc_ids].present?
         if session[:viewed_doc_ids].include?(doc_id)
           return false
         else
           return true
         end
       else
         return true
       end
   end

end
