# Based on the Module#prepend pattern in ruby which is used in some Hyrax.
# Uses the to_prepare Rails hook in application.rb to inject this module to override Hyrax::Forms::CollectionForm module
module PrependedForms::CollectionForm
  module ClassMethods
    # Override Hyrax::Forms::CollectionForm.terms method
    # self.terms = [:parent_agency, :title, :acronym, :description, :contact_email, :contact_phone,
    #               :location_city, :location_state, :homepage_url, :is_division]
    def terms
      [:resource_type, :title, :creator, :contributor, :description,
                    :keyword, :license, :publisher, :date_created, :subject, :language,
                    :representative_id, :thumbnail_id, :identifier, :based_near,
                    :related_url, :visibility, :collection_type_gid, :title_sort]
    end
  end

  def self.prepended(base)
    class << base
      prepend ClassMethods
    end
  end

  delegate :title_sort, to: :model
  delegate :blacklight_config, to: Hyrax::CollectionsController
  # Override Hyrax::Forms::CollectionForm#primary_terms method
  # Terms that appear within the accordion.  Show all terms without an additional metadata button.
  def primary_terms
    [:title, :description]
  end

  # Terms that appear within the accordion
  # Override Hyrax::Forms::CollectionForm#secondary_terms method
  # Terms that appear within the accordion.  All metadata is considered primary.  No additional metadata.
  def secondary_terms
    [:creator,
     :contributor,
     :keyword,
     :license,
     :publisher,
     :date_created,
     :subject,
     :language,
     :identifier,
     :based_near,
     :related_url,
     :resource_type,
     :title_sort]
  end
end