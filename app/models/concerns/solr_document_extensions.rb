# frozen_string_literal: true
module SolrDocumentExtensions
  extend ActiveSupport::Concern
  # include Permissions::Readable

  include SolrDocumentExtensions::GenericWork
end
