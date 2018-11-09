# frozen_string_literal: true
module SolrDocumentExtensions::GenericWork
  extend ActiveSupport::Concern

  def value_chain
    self[Solrizer.solr_name('value_chain')]
  end
  
  def commodities
    self[Solrizer.solr_name('commodities')]
  end

  def title_sort
    self[Solrizer.solr_name('title_sort')]
  end

end
