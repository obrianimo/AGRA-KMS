module API
  module V1
    class CollectionsController < BaseController
      # before_action :authenticate
      protect_from_forgery with: :null_session
      def initialize
        @fq = "has_model_ssim:Collection"
        @max_rows = ActiveFedora::SolrService::MAX_ROWS
        @fl = ['id', 'title_tesim', 'depositor_ssim', 'collection_type_gid_ssim', 'visibility_ssi', 'nesting_collection__parent_ids_ssim']
      end
            
      def findAll
        query = "*:*"
        collections = ActiveFedora::SolrService.query(query, fq: @fq, fl: @fl, rows: @max_rows)
        format_solr_keys(collections)
        render(json: collections)
      end
      
      def findByID
        query = "id:" + params[:id].to_s
        collections = ActiveFedora::SolrService.query(query, fq: @fq, fl: @fl, rows: @max_rows)
        format_solr_keys(collections)
        render(json: collections)
      end

    end
  end
end
