module Hyrax
  class CollectionsController < ApplicationController
    include CollectionsControllerBehavior
    include BreadcrumbsForCollections
    with_themed_layout :decide_layout
    load_and_authorize_resource except: [:index, :show, :create], instance_name: :collection

    # Renders a JSON response with a list of files in this collection
    # This is used by the edit form to populate the thumbnail_id dropdown
    def files
      result = form.select_files.map do |label, id|
        { id: id, text: label }
      end
      render json: result
    end

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

    private

      def form
        @form ||= form_class.new(@collection, current_ability, repository)
      end

      def decide_layout
        layout = case action_name
                 when 'show'
                   '1_column'
                 else
                   'dashboard'
                 end
        File.join(theme, layout)
      end
  end
end
