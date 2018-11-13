# Generated via
#  `rails generate hyrax:work GenericWork`
module Hyrax
  class GenericWorkPresenter < Hyrax::WorkShowPresenter
    # add title_sort to fields once it works
    delegate :commodities, :value_chain, to: :solr_document    
  end
end
