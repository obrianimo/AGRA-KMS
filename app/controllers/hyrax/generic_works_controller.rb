# Generated via
#  `rails generate hyrax:work GenericWork`
module Hyrax
  # Generated controller for GenericWork
  class GenericWorksController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::GenericWork

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::GenericWorkPresenter

#     def attributes_for_actor
#       raw_params = params[hash_key_for_curation_concern]
#       raw_params[:title_sort] = set_title_sort(raw_params)
#       attributes = if raw_params
#                      work_form_service.form_class(curation_concern).model_attributes(raw_params)
#                    else
#                      {}
#                    end
#       attributes
#     end

  end
end
