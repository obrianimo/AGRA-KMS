class FileDownloadsController < ApplicationController
    include Hydra::Controller::DownloadBehavior
    include Hyrax::LocalFileDownloadsControllerBehavior

    def self.default_content_path
      :original_file
    end

    # Render the 404 page if the file doesn't exist.
    # Otherwise renders the file.
    def show
      case file
      when ActiveFedora::File
        update_public_usage_stats
        # For original files that are stored in fedora
        super
      when String
        # For derivatives stored on the local file system
        send_local_content
      else
        raise ActiveFedora::ObjectNotFoundError
      end
    end

    private

      def update_public_usage_stats
        # For some reason the Hydra code runs through the show action twice the first
        # a file is downloaded. That's why we set and check the session variable.
        # This also combats bots that will download the same file multiple times per session.
        # SQL (0.2ms)  INSERT INTO `public_usage_stats` (`id`, `file_id`, `downloads`, `views`, `created_at`, `last_downloaded_at`) VALUES (0, '0r967372b', 1, 0, '2020-05-18 19:09:01', '2020-05-18 19:09:01')
        
        doc_fields = get_document_id_and_title(params[:id])
        id = doc_fields[0]
        title = doc_fields[1]
        if updateUsageStatsCheck(params[:id])
          @usage_stats = PublicUsageStats.find_or_initialize_by(:file_id => id)
          if @usage_stats.title.present?
            @usage_stats.update(:last_downloaded_at => Time.current, :downloads => @usage_stats.downloads + 1)
          else
            @usage_stats.title = title
            @usage_stats.last_downloaded_at = Time.current
            @usage_stats.downloads = 1
            @usage_stats.views = 0
            @usage_stats.created_at = Time.current
            @usage_stats.save
          end

          (session[:downloaded_doc_ids] ||= []) << params[:id]

          # setting the expires header keeps the browser from caching the page so we can track
          # any additional downloads of the file
          hdr_date = DateTime.current.tomorrow.to_formatted_s(:rfc822).gsub("+0000","GMT")
          response.headers["Expires"] = hdr_date
        end
      end

      def updateUsageStatsCheck(doc_id)
        # if the request isn't using the form, it's a bot, return false
          if session[:downloaded_doc_ids].present?
            if session[:downloaded_doc_ids].include?(doc_id)
              return false
            else
              return true
            end
          else
            return true
          end
      end
    
      def get_document_id_and_title(id)
          uri = URI.parse(ENV['SOLR_URL'] + '/select?q=hasRelatedMediaFragment_ssim%3A' + id + '&fq=has_model_ssim%3AGenericWork&fl=title_tesim,id&wt=json&indent=true&qt=standard')
          http = Net::HTTP.new(uri.host, uri.port)
        	req = Net::HTTP::Get.new(uri.request_uri)
        	rsp = http.request(req)
        	if rsp.to_s.include?("HTTPNotFound")
        	  return 0
        	end
        	body = JSON.parse(rsp.body)
          id = "unknown"
        	title = "unknown"
          if body != nil && body["response"]["numFound"] != 0
        	  id = body["response"]["docs"][0]["id"]
        	  title = body["response"]["docs"][0]["title_tesim"][0]
        	end
        	return [id, title]
      end

      # Override the Hydra::Controller::DownloadBehavior#content_options
      def content_options
        super.merge(disposition: 'inline')
      end
    
          # Override this method if you want to change the options sent when downloading
      # a derivative file
      def derivative_download_options
        { type: mime_type_for(file), disposition: 'inline' }
      end

      # Customize the :read ability in your Ability class, or override this method.
      # Hydra::Ability#download_permissions can't be used in this case because it assumes
      # that files are in a LDP basic container, and thus, included in the asset's uri.
      def authorize_download!
        authorize! :download, params[asset_param_key]
      rescue CanCan::AccessDenied
        unauthorized_image = Rails.root.join("app", "assets", "images", "unauthorized.png")
        if File.exist? unauthorized_image
          send_file unauthorized_image, status: :unauthorized
        else
          Deprecation.warn(self, "redirect_to default_image is deprecated and will be removed from Hyrax 3.0 (copy unauthorized.png image to directory assets/images instead)")
          redirect_to default_image
        end
      end

      def default_image
        ActionController::Base.helpers.image_path 'default.png'
      end

      # Overrides Hydra::Controller::DownloadBehavior#load_file, which is hard-coded to assume files are in BasicContainer.
      # Override this method to change which file is shown.
      # Loads the file specified by the HTTP parameter `:file`.
      # If this object does not have a file by that name, return the default file
      # as returned by {#default_file}
      # @return [ActiveFedora::File, File, NilClass] Returns the file from the repository or a path to a file on the local file system, if it exists.
      def load_file
        file_reference = params[:file]
        return default_file unless file_reference

        file_path = Hyrax::DerivativePath.derivative_path_for_reference(params[asset_param_key], file_reference)
        File.exist?(file_path) ? file_path : nil
      end

      def default_file
        default_file_reference = if asset.class.respond_to?(:default_file_path)
                                   asset.class.default_file_path
                                 else
                                   FileDownloadsController.default_content_path
                                 end
        association = dereference_file(default_file_reference)
        association&.reader
      end

      def mime_type_for(file)
        MIME::Types.type_for(File.extname(file)).first.content_type
      end

      def dereference_file(file_reference)
        return false if file_reference.nil?
        association = asset.association(file_reference.to_sym)
        association if association && association.is_a?(ActiveFedora::Associations::SingularAssociation)
      end
end
