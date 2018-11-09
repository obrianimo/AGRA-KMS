module DisplayHelper
  
  def get_collection_branding_info(id)
    cbi = CollectionBrandingInfo.where(collection_id: id)
    return cbi
  end
  # Add special body class for home page
  def render_home_class
    if request.original_fullpath == '/'
      ' home'
    end
  end

  # Render Agriknowledge version 
  def agriknowledge_version
    version=`/bin/cat .app-version`
    return version
  end

  # Renders the link to the full text file
  def render_document_link args
    fulltext_path = args[:document][args[:field]] unless args[:document][args[:field]].blank?
    if fulltext_path.present?
      # This all hinges on symbolic link in public directory (to /teeal/documents)
      path = "/downloads/#{fulltext_path}"
      link_to path, target: "_blank", class: "btn btn-sm btn-success" do
        '<i class="fa fa-file-text"></i> View full text'.html_safe
      end
    end
  end

  def render_search_link args
    items = args[:document][args[:field]] unless args[:document][args[:field]].blank?
    field = [args[:field]][0]
    if items.present?
        self.process_field(items, field)
    end
  end

  def process_field items, field
    display = ""
    case field
    when "commodities_facet"
      items.each_with_index do |item, index|
        sub = item.gsub(" ","+")
        display += '<a href="/?f[commodities_facet][]=' + sub + '">' + item + '</a>'
        if index < items.length - 1
          display += ", "
        end
      end
    when "valueChain_facet"
      items.each_with_index do |item, index|
        sub = item.gsub(" ","+")
        display += '<a href="/?f[valueChain_facet][]=' + sub + '">' + item + '</a>'
        if index < items.length - 1
          display += ", "
        end
      end
    when "subject_facet"
      items.each_with_index do |item, index|
        sub = item.gsub(" ","+")
        display += '<a href="/?f[subject_facet][]=' + sub + '">' + item + '</a>'
        if index < items.length - 1
          display += ", "
        end
      end
    else
      display = items.to_s + "oops"
    end

    return display.html_safe
  end
  
  # collection facet specific versions because we need to filter out private collections
  def render_collection_facet_limit_list(paginator, facet_field, wrapping_element = :li)
      safe_join(paginator.items.map { |item| render_collection_facet_item(facet_field, item) }.compact.map { |item| content_tag(wrapping_element, item) })
  end

  ##
  # Renders a single facet item
  def render_collection_facet_item(facet_field, item)
    if is_discoverable_collection(item.value)
      if facet_in_params?(facet_field, item.value)
        render_selected_facet_value(facet_field, item)
      else
        render_facet_value(facet_field, item)
      end
    end
  end

  def is_discoverable_collection(id)
    solr_docs = controller.repository.find(id).docs
    ct_gid = solr_docs.first.collection_type_gid
    ct = Hyrax::CollectionType.find_by_gid!(ct_gid)
    Rails.logger.info("COLLECTION TYPE = " + ct.inspect)
    if ct.machine_id == "public"
      return true
    else
      return false
    end
  end

end
