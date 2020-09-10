# frozen_string_literal: true
module SolrDocumentExtensions::Collection
  extend ActiveSupport::Concern

  def title_sort
    self[Solrizer.solr_name('title_sort')]
  end
  
end
