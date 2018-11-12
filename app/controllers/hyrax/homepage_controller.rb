class Hyrax::HomepageController < ApplicationController
  # Adds Hydra behaviors into the application controller
  include Blacklight::SearchContext
  include Blacklight::SearchHelper
  include Blacklight::AccessControls::Catalog
  
  before_action :set_commodities_list
  before_action :set_geo_location_list
  # before_action :set_value_chain_list
  before_action :set_collection_list
  before_action :set_language_list
  before_action :set_collection_list
  
  def set_commodities_list
    commodities_list = get_facet_list('commodities')
    if commodities_list == 0
      session[:commodities_list] = []
    else
      session[:commodities_list] = commodities_list
    end
  end

  def set_geo_location_list
    geo_location_list = get_facet_list('based_near')
    if geo_location_list == 0
      session[:geo_location_list] = []
    else
      session[:geo_location_list] = geo_location_list
    end
  end

#   def set_value_chain_list
#       value_chain_list = get_facet_list('value_chain')
#       if value_chain_list == 0
#         session[:value_chain_list] = []
#       else
#         session[:value_chain_list] = value_chain_list
#       end
#   end

  # TODO: Needs work to dislpay collections
  def set_collection_list
    # byebug  
    collection_list = get_facet_list('member_of_collections')
    if collection_list == 0
      session[:collection_list] = []
    else
      session[:collection_list] = collection_list
    end
  end

  def set_language_list
    language_list = get_facet_list('language')
    if language_list == 0
      session[:language_list] = []
    else
      session[:language_list] = language_list
    end
  end
  

  # The search builder for finding recent documents
  # Override of Blacklight::RequestBuilders
  def search_builder_class
    Hyrax::HomepageSearchBuilder
  end

  class_attribute :presenter_class
  self.presenter_class = Hyrax::HomepagePresenter
  layout 'homepage'
  helper Hyrax::ContentBlockHelper

  def index
    @presenter = presenter_class.new(current_ability, collections)
    @featured_researcher = ContentBlock.for(:researcher)
    @marketing_text = ContentBlock.for(:marketing)
    @featured_work_list = FeaturedWorkList.new
    @announcement_text = ContentBlock.for(:announcement)
    recent
  end

  private

    # Return 5 collections
    def collections(rows: 5)
      builder = Hyrax::CollectionSearchBuilder.new(self)
                                              .rows(rows)
      response = repository.search(builder)
      response.documents
    rescue Blacklight::Exceptions::ECONNREFUSED, Blacklight::Exceptions::InvalidRequest
      []
    end

    def recent
      # grab any recent documents
      (_, @recent_documents) = search_results(q: '', sort: sort_field, rows: 4)
    rescue Blacklight::Exceptions::ECONNREFUSED, Blacklight::Exceptions::InvalidRequest
      @recent_documents = []
    end

    def sort_field
      "#{Solrizer.solr_name('system_create', :stored_sortable, type: :date)} desc"
    end

    def get_facet_list(type)
      Rails.logger.info("SOLR_URL = " + ENV['SOLR_URL'].to_s)
      if type == 'commodities'
        facet_field = 'commodities_sim'
      elsif type == 'based_near'
        facet_field = 'based_near_sim'
      elsif type == 'language'
        facet_field = 'language_sim'
      else
        facet_field = 'member_of_collections_ssim'
      end
      uri = URI.parse(ENV['SOLR_URL'] + '/select?facet=on&q=*:*&rows=0&wt=json&indent=true&facet=true&facet.field=' + facet_field + '&facet.sort=index&facet.limit=-1&qt=standard')
      http = Net::HTTP.new(uri.host, uri.port)
    	req = Net::HTTP::Get.new(uri.request_uri)
    	rsp = http.request(req)
    	if rsp.to_s.include?("HTTPNotFound")
    	  return 0
    	end
    	body = eval(rsp.body)
    	fields = []
      if body != nil
        Rails.logger.info("BODY = " + body.to_s)  
        if type == 'commodities' 
          result = body[:facet_counts][:facet_fields][:commodities_sim]
        elsif type == 'based_near'
          result = body[:facet_counts][:facet_fields][:based_near_sim]
        # elsif type == 'value_chain'
        #   result = body[:facet_counts][:facet_fields][:value_chain_sim]
        elsif type == 'member_of_collections'
          result = body[:facet_counts][:facet_fields][:member_of_collections_ssim]
        else
          result = body[:facet_counts][:facet_fields][:language_sim]
        end 
        if result != nil 
          result.each do |x|
            if x.class.name.to_s == "String"
              fields << x
            end
          end
        end
    	end
    	return fields
    end
end
