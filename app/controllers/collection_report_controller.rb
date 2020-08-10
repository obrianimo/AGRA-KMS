class CollectionReportController < ApplicationController
  # Adds Hydra behaviors into the application controller
  include Blacklight::SearchContext
  include Blacklight::SearchHelper
  include Blacklight::AccessControls::Catalog
  
  before_action :authenticate_user!
  before_action :authorize_admin
  with_themed_layout 'dashboard'

  def index
    @start_at = params[:start].present? ? params[:start] : 0
    @prev = params[:prev].present? ? params[:prev] : 0
    @query_type = params[:query_type].present? ? params[:query_type] : "summary"
    @per_page = 20 if @query_type == "summary"    
    @per_page = 5 if @query_type == "detailed"
    raw_collections = collections[0] #@presenter.
    docs = raw_collections.response["response"]["docs"]
    @num_found = raw_collections.response["response"]["numFound"]
    coll_array = []
    docs.each do |d|
      @item_count = ActiveFedora::Base.where("member_of_collection_ids_ssim:#{d['id']} AND generic_type_sim:Work").accessible_by(current_ability).count
      items = ActiveFedora::Base.where("member_of_collection_ids_ssim:#{d['id']} AND generic_type_sim:Work").accessible_by(current_ability)
      tmp_hash  = {}
  	  tmp_hash["id"] = d['id']
  	  tmp_hash["title"] = d['title_tesim'][0]
  	  tmp_hash["creator"] = d['depositor_tesim'][0]
  	  tmp_hash["item_count"] = @item_count
  	  tmp_hash["created"] = d['system_create_dtsi']
  	  tmp_hash["modified"] = d['system_modified_dtsi']
  	  tmp_hash["items"] = items
  	  coll_array << tmp_hash
  	end
  	@collections = coll_array.sort_by! {|d| d['title']}
  	
  end

  private

    # Return 1000 collections.
    def collections(rows: 1000)
      builder = Hyrax::CollectionSearchBuilder.new(self)
                                              .rows(rows)
      response = repository.search(builder)
      response.documents
    rescue Blacklight::Exceptions::ECONNREFUSED, Blacklight::Exceptions::InvalidRequest
      []
    end

end
