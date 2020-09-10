class UsageReportsController < ApplicationController

  require "csv"

  before_action :authenticate_user!
  before_action :authorize_admin
  with_themed_layout 'dashboard'
    
  def index
    if params[:reportType].present? 
      if params[:reportType] == "usage_stats"
        @per_page = params[:per_page].blank? ? 10 : params[:per_page].to_i
        count = get_view_and_download_count
        @public_usage = get_view_and_download_history(@per_page)
        @top_navigation = build_top_navigation(@per_page, count[0].the_count)
        @bottom_navigation = build_bottom_navigation(@per_page, count[0].the_count)
      end
    end
  end
  
  def get_view_and_download_history(per_page)
    # check for a sort param first; if none, sort by title
    if !params[:sort].present? 
      sort = "title"
    elsif params[:sort] == "title" 
      sort = params[:sort]
    else
      sort = params[:sort] + " desc"      
    end
    
    limit = " limit 0, " + per_page.to_s
    
    if per_page == -1
      limit = ""
    elsif params[:page].present?
      start_at = ((params[:page].to_i - 1) * per_page)   
      limit = " limit " + start_at.to_s + " , " + per_page.to_s
    end
    
    if params[:title].present?
      @data = PublicUsageStats.find_by_sql("SELECT * FROM public_usage_stats WHERE LOWER(title) like '%" + params[:title].downcase + "%' ORDER BY " + sort + limit + ";")
      return @data
    else
      @data = PublicUsageStats.find_by_sql("SELECT * FROM public_usage_stats ORDER BY " + sort + limit + ";")
      return @data
    end
  end
  
  def get_view_and_download_count
    if params[:title].present?
      title_string = "WHERE LOWER(title) like '%" + params[:title].downcase + "%'"
    else
      title_string = ""
    end
    @data = PublicUsageStats.find_by_sql("SELECT count(*) AS the_count FROM public_usage_stats " + title_string + ";")
    return @data
  end

  def build_top_navigation(per_page, the_count)
    sort_string =  params[:sort].blank? ? "" : params[:sort] 
    per_page_string =  params[:per_page].blank? ? "" : params[:per_page] 
    title_string =  params[:title].blank? ? "" : params[:title] 
		prev_string = "« Previous"
		next_string = "<a rel=\"next\" href=\"usage_stats?page=2&amp;sort=" + sort_string + "&amp;title=" + title_string + "&amp;title=" + title_string + "&amp;per_page=" + per_page_string + "\">Next »</a>"
		range_string = "<span class=\"page_entries\"> | <strong>1</strong> - <strong>" + per_page.to_s + "</strong> of <strong>" + the_count.to_s + "</strong> | "
		if the_count > per_page
			if params[:page].present?
				first_row = ((params[:page].to_i - 1) * per_page + 1)
				last_row = ((first_row + per_page) - 1)
				if first_row == the_count 
					range_string = " | <strong>" + first_row.to_s + " of " + the_count.to_s + "</strong> |"
				elsif (the_count - first_row) < per_page
					range_string = " | <strong>" + first_row.to_s + "</strong> - <strong>" + the_count.to_s + "</strong> of <strong>" + the_count.to_s + "</strong> |"
				else
					range_string = " | <strong>" + first_row.to_s + "</strong> - <strong>" + last_row.to_s + "</strong> of <strong>" + the_count.to_s + "</strong> |"
				end
				prev_page = (params[:page].to_i - 1).to_s
				prev_string = "<a rel=\"next\" href=\"usage_stats?page=" + (prev_page == '1' ? '' : prev_page) + "&amp;sort=" + sort_string + "&amp;title=" + title_string + "&amp;per_page=" + per_page_string + "\">« Previous</a>"
				if (params[:page].to_i * per_page) < the_count
					next_page = (params[:page].to_i + 1).to_s
					next_string = "<a rel=\"next\" href=\"usage_stats?page=" + next_page + "&amp;sort=" + sort_string + "&amp;title=" + title_string + "&amp;per_page=" + per_page_string + "\"> Next »</a>"
				else
					next_string = " Next »"
				end
			end
		else
		  prev_string = "" 
		  range_string = "<span class=\"page_entries\"> | <strong>1</strong> - <strong>" + the_count.to_s + "</strong> of <strong>" + the_count.to_s + "</strong> | "
		  next_string = ""
		end
		range_string += "</span>"
		return prev_string + range_string + next_string
  end
  
  def build_bottom_navigation(per_page, the_count)
    if the_count <= per_page
      return ""
    else
      prev_string = ""
    	next_string = ""
    	page_list = ""
  		first_two = ""
  		last_two = ""
  		ellipsis = " . . . "
  
    	sort_string = params[:sort].blank? ? "" : params[:sort] 
      per_page_string =  params[:per_page].blank? ? "" : params[:per_page] 
      title_string =  params[:title].blank? ? "" : params[:title] 
    	curr_page = params[:page].blank? ? 1 : params[:page].to_i 
    	page_count = (the_count/per_page.to_f).ceil
    	the_count = the_count
  
    	if (the_count < 100) 
    		if curr_page == 1
    			page_list += " 1 "
    			prev_string += "« Previous "
    			next_string += "<a rel=\"next\" href=\"usage_stats?page=2&amp;sort=" + sort_string + "&amp;title=" + title_string + "&amp;per_page=" + per_page_string + "\">Next »</a>"
    		else
    			page_list += "<a href=\"usage_stats?sort=" + sort_string + "&amp;title=" + title_string + "&amp;per_page=" + per_page_string + "\">1</a>"
    		end
    		(2..page_count).each do |i|
    			if i == curr_page
    				page_list += " " + i.to_s + " "
    			else
    				page_list += "<a href=\"usage_stats?sort=" + sort_string + "&amp;title=" + title_string + "&amp;per_page=" + per_page_string + "&amp;page=" + i.to_s + "\"> " + i.to_s + " </a>"
    			end
    		end
    		if prev_string.length == 0
    			prev_string += "<a rel=\"next\" href=\"usage_stats?page=" + (curr_page - 1).to_s + "&amp;sort=" + sort_string + "&amp;title=" + title_string + "&amp;per_page=" + per_page_string + "\">« Previous </a>"
    		end
  
    		if next_string.length == 0
    			if (curr_page) < page_count
    				next_string += "<a rel=\"next\" href=\"usage_stats?page=" + (curr_page + 1).to_s + "&amp;sort=" + sort_string + "&amp;title=" + title_string + "&amp;per_page=" + per_page_string + "\"> Next »</a>"
    			else
    				next_string = "Next »"
    			end
    		end
    	else
    		if curr_page > (page_count / 2)
    			first_two += "<a rel=\"next\" href=\"usage_stats?page=1&amp;sort=" + sort_string + "&amp;title=" + title_string + "&amp;per_page=" + per_page_string + "\"> 1 </a>"
    			first_two += "<a rel=\"next\" href=\"usage_stats?page=2&amp;sort=" + sort_string + "&amp;title=" + title_string + "&amp;per_page=" + per_page_string + "\"> 2 </a>" + ellipsis
  
    				if (page_count - curr_page) <= 6
    					((curr_page - 4)..page_count).each do |i|
    						if i == curr_page
    							page_list += " " + i.to_s + " "
    						else
    							page_list += "<a href=\"usage_stats?sort=" + sort_string + "&amp;title=" + title_string + "&amp;per_page=" + per_page_string + "&amp;page=" + i.to_s + "\"> " + i.to_s + " </a>"
    						end
    					end
    				else
    					((curr_page - 4)..(curr_page + 4)).each do |i|
    						if i == curr_page
    							page_list += " " + i.to_s + " "
    						else
    							page_list += "<a href=\"usage_stats?sort=" + sort_string + "&amp;page=" + i.to_s + "&amp;title=" + title_string + "&amp;per_page=" + per_page_string + "\"> " + i.to_s + " </a>"
    						end
    					end
    					last_two += ellipsis + "<a rel=\"next\" href=\"usage_stats?page=" + (page_count - 1).to_s + "&amp;sort=" + sort_string + "&amp;title=" + title_string + "&amp;per_page=" + per_page_string + "\"> " + (page_count - 1).to_s + " </a>"
    					last_two += "<a rel=\"next\" href=\"usage_stats?page=" + page_count.to_s + "&amp;sort=" + sort_string + "&amp;title=" + title_string + "&amp;per_page=" + per_page_string + "\"> " + page_count.to_s + " </a>"
    				end
    		elsif curr_page < (page_count / 2)
    			last_two += ellipsis + "<a rel=\"next\" href=\"usage_stats?page=" + (page_count - 1).to_s + "&amp;sort=" + sort_string + "&amp;title=" + title_string + "&amp;per_page=" + per_page_string + "\">" + (page_count - 1).to_s + " </a>"
    			last_two += "<a rel=\"next\" href=\"usage_stats?page=" + (page_count).to_s + "&amp;sort=" + sort_string + "&amp;title=" + title_string + "&amp;per_page=" + per_page_string + "\">" + (page_count).to_s + " </a>" 
  
    			if curr_page <= 6
    				(1..(curr_page + 4)).each do |i|
    					if i == curr_page
    						page_list += " " + i.to_s + " "
    					else
    						page_list += "<a href=\"usage_stats?sort=" + sort_string + "&amp;page=" + i.to_s + "&amp;title=" + title_string + "&amp;per_page=" + per_page_string + "\"> " + i.to_s + " </a>"
    					end
    				end
    			else
    				first_two += "<a rel=\"next\" href=\"usage_stats?page=1&amp;sort=" + sort_string + "&amp;title=" + title_string + "&amp;per_page=" + per_page_string + "\"> 1 </a>"
    				first_two += "<a rel=\"next\" href=\"usage_stats?page=2&amp;sort=" + sort_string + "&amp;title=" + title_string + "&amp;per_page=" + per_page_string + "\"> 2 </a>" + ellipsis
    				((curr_page - 4)..(curr_page + 4)).each do |i|
    					if i == curr_page
    						page_list += " " + i.to_s + " "
    					else
    						page_list += "<a href=\"usage_stats?sort=" + sort_string + "&amp;page=" + i.to_s + "&amp;title=" + title_string + "&amp;per_page=" + per_page_string + "\"> " + i.to_s + " </a>"
    					end
    				end
    			end
    		end		
    		if curr_page > 1
    			prev_string += "<a rel=\"next\" href=\"usage_stats?page=" + (curr_page - 1).to_s + "&amp;sort=" + sort_string + "&amp;title=" + title_string + "&amp;per_page=" + per_page_string + "\">« Previous </a>"
    		else
    			prev_string = "« Previous "
    		end
  
    		if curr_page < page_count
    			next_string += "<a rel=\"next\" href=\"usage_stats?page=" + (curr_page + 1).to_s + "&amp;sort=" + sort_string + "&amp;title=" + title_string + "&amp;per_page=" + per_page_string + "\"> Next »</a>"
    		else
    			next_string = " Next »"
    		end			
    	end
    	return prev_string + first_two + page_list + last_two + next_string
    end
  end

  def download_report
    public_usage = get_view_and_download_history(-1)
    tempfile = Tempfile.new("temp_report_file_#{Time.now.strftime('%m-%d-%Y')}.csv") 
    file_name = "usage_report_#{Time.now.strftime('%m-%d-%Y')}.csv"
    CSV.open(tempfile.path, "w") do |csv|
      csv << ["Usge Report", Date.today]
      csv <<  ["Title", "Views", "Last View", "Downloads", "Last Download"]
      public_usage.each do |u|
        last_viewed = u.last_viewed_at.present? ? u.last_viewed_at.to_date.strftime("%d %B %Y") : ""
        downloads = u.downloads.present? ? u.downloads : 0
        last_download = u.last_downloaded_at.present? ? u.last_downloaded_at.to_date.strftime("%d %B %Y") : ""
        csv << [u.title, u.views, last_viewed, downloads, last_download]
      end
    end
    
    send_file tempfile.path, :type => 'text',
                        :disposition => 'attachment',
                        :filename => file_name
    tempfile.close
  end
end
