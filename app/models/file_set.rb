# Generated by hyrax:models:install
class FileSet < ActiveFedora::Base

# property :title_sort, predicate: ::RDF::URI.new('http://www.teeal.org/ns#fileSetTitleSortField'), multiple: true do |index|
#   index.as :stored_searchable, :stored_sortable
# end
  
  include ::Hyrax::FileSetBehavior
end
