module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior

  def convert_id_to_name(id)
    solr_docs = controller.repository.find(id).docs
    solr_field = solr_docs.first[Solrizer.solr_name("title", :stored_searchable)]
    if solr_field != nil
      return solr_field.first
    end
  end

  def collection_title_by_id(options={})
    titles = ""
    values = options[:value]
    values.each do |value|
       col = Collection.find(value)
       titles = titles +", "+ col.title.first unless col.nil?
    end 
    titles.delete_prefix(', ').delete_suffix(', ')
  end
  
end
