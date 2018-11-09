# Generated via
#  `rails generate hyrax:work GenericWork`
module Hyrax
  class GenericWorkPresenter < Hyrax::WorkShowPresenter
    delegate :commodities, :value_chain, :title_sort, to: :solr_document    
  end
end
