# Based on the Module#prepend pattern in ruby which is used in some Hyrax.
# Uses the to_prepare Rails hook in application.rb to inject this module to override Hyrax::CollectionPresenter module
module PrependedPresenters::CollectionPresenter
  module ClassMethods
    # Override Hyrax::CollectionPresenter.terms method
    def terms
      [:total_items, :size, :resource_type, :creator, :contributor, :keyword, :license, :publisher, :date_created, :subject,
       :language, :identifier, :based_near, :related_url]
    end
  end

  def self.prepended(base)
    class << base
      prepend ClassMethods
    end
  end

  delegate :title, :description, :creator, :contributor, :subject, :publisher, :keyword, :language, :embargo_release_date,
           :lease_expiration_date, :license, :date_created, :resource_type, :based_near, :related_url, :identifier, :thumbnail_path,
           :title_or_label, :collection_type_gid, :create_date, :modified_date, :visibility, :edit_groups, :edit_people, :title_sort,
           to: :solr_document

end