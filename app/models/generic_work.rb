# Generated via
#  `rails generate hyrax:work GenericWork`
class GenericWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = GenericWorkIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }
  # self.human_readable_type = 'Document'
  property :value_chain, predicate: ::RDF::URI.new('http://www.teeal.org/ns#valueChain') do |index|
    index.as :stored_searchable, :facetable
  end

  property :commodities, predicate: ::RDF::URI.new('http://www.teeal.org/ns#commodity') do |index|
    index.as :stored_searchable, :facetable
  end

#  property :title_sort, predicate: ::RDF::URI.new('http://www.teeal.org/ns#titleSortField'), multiple: true do |index|
#    index.as :stored_searchable, :stored_sortable
#  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
