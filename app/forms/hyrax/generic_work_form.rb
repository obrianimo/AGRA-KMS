# Generated via
#  `rails generate hyrax:work GenericWork`
module Hyrax
  # Generated form for GenericWork
  class GenericWorkForm < Hyrax::Forms::WorkForm
    self.model_class = ::GenericWork
    
    self.terms = [:title, :creator, :contributor, :description, :resource_type,
                  :keyword, :based_near, :value_chain, :commodities, :subject, :language, :license, :rights_statement, 
                  :publisher, :date_created, :identifier, :related_url, :source, 
                  :representative_id, :thumbnail_id, :rendering_ids, :files,
                  :visibility_during_embargo, :embargo_release_date, :visibility_after_embargo,
                  :visibility_during_lease, :lease_expiration_date, :visibility_after_lease,
                  :visibility, :ordered_member_ids, :in_works_ids,
                  :member_of_collection_ids, :admin_set_id, :title_sort]

    self.required_fields = [:title, :rights_statement]
  end
end
