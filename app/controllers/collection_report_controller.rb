class CollectionReportController < ApplicationController
  require "csv"
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
    @selected_collection = params[:collect].present? ? params[:collect] : ""
    @query_type = params[:query_type].present? ? params[:query_type] : "summary"
    @per_page = 15 if @query_type == "summary"    
    @per_page = 5 if @query_type == "detailed"
    raw_collections = collections[0]
    docs = raw_collections.response["response"]["docs"] if @query_type == "summary"
    docs = raw_collections.response["response"]["docs"].select {|x| x["title_tesim"][0] == @selected_collection} if @query_type == "detailed"
    @num_found = raw_collections.response["response"]["numFound"]
    coll_array = process_the_docs(docs)
  	@collections = coll_array.sort_by! {|d| d['title']}
  	@titles = collection_titles.sort
  end
  
  def process_the_docs(docs)
    coll_array = []
    docs.each do |d|
      @item_count = ActiveFedora::Base.where("member_of_collection_ids_ssim:#{d['id']} AND generic_type_sim:Work").accessible_by(current_ability).count
      items = ActiveFedora::Base.where("member_of_collection_ids_ssim:#{d['id']} AND generic_type_sim:Work").accessible_by(current_ability)
      tmp_hash  = {}
  	  tmp_hash["id"] = d['id']
  	  tmp_hash["title"] = d['title_tesim'][0]
  	  tmp_hash["creator"] = d['depositor_tesim'][0]
  	  tmp_hash["item_count"] = @item_count
  	  tmp_hash["created"] = d['system_create_dtsi'].present? ? d['system_create_dtsi'][0..9] : "not found "
  	  tmp_hash["modified"] = d['system_modified_dtsi'].present? ? d['system_modified_dtsi'][0..9] : "not found "
  	  tmp_hash["items"] = items
  	  coll_array << tmp_hash
  	  @items = items if @query_type == "detailed"
  	end
  	return coll_array
  end
  
  def download_report
    tempfile = Tempfile.new("temp_report_file_#{Time.now.strftime('%m-%d-%Y')}.csv") 
    raw_collections = collections[0]
    docs = raw_collections.response["response"]["docs"]
    coll_array = process_the_docs(docs)
    file_name = "collections_report_#{Time.now.strftime('%m-%d-%Y')}.csv"
    CSV.open(tempfile.path, "w") do |csv|
      csv << ["Collections Report", Date.today]
      csv <<  ["Collection name", "Items", "Created by", "Created on", "Last updated", "Titles"]
      collections = coll_array.sort_by! {|d| d['title']}
      collections.each do |c|
        titles = ""
        if c['items'].size > 0
          c['items'].each do |i|
            titles += i.title[0]
            titles += ", " unless i == c['items'].last
          end
          
        end
        csv << [c['title'], c['item_count'], c['creator'], c['created'], c['modified'], titles]
      end
    end
    
    send_file tempfile.path, :type => 'text',
                        :disposition => 'attachment',
                        :filename => file_name
    tempfile.close
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

    def collection_titles
      tmp = Collection.all
      coll_array = []
      tmp.each do |c|
        coll_array << c.title[0]
      end
      return coll_array
    end
    
end
