class SearchHistoryController < ApplicationController

  require "csv"

  before_action :authenticate_user!
  before_action :authorize_admin
  with_themed_layout 'dashboard'
    
  def index
    # results = Searches.find_by_sql("SELECT query_params FROM searches WHERE query_params LIKE '%q:%' or query_params LIKE '%f:%';")
    months_back = params[:query_range].nil? ? 3 : params[:query_range].to_i
    date_back = Date.today - months_back.months
    created_at = date_back.strftime('%Y-%m-%d')
    Rails.logger.info("************************ created_at = " + created_at.inspect)
    Rails.logger.info("************************ query string = SELECT query_params FROM searches WHERE query_params LIKE '%q:%' AND created_at > '#{created_at}' LIMIT 40;")
    results = Searches.find_by_sql("SELECT query_params FROM searches WHERE query_params LIKE '%q:%' AND created_at > '#{created_at}';")
    @queries = []
    @query_range = params[:query_range]
    tmp_array = []
    results.each do |r|
      tmp = r[:query_params].gsub("--- ","").gsub("!ruby/hash:ActiveSupport::HashWithIndifferentAccess\n","").gsub("_ssim","").gsub("_sim","")
      tmp = tmp.gsub("\naction"," | action").gsub("\ncontroller"," | controller").gsub("\nsearch_field"," | search_field").gsub(":\n",":").gsub("\nq:"," | q:")
      tmp = tmp.gsub("\nview:"," | view:").gsub("\nlocale:"," | locale:").gsub("index\n","index")
      if tmp.include?("utf")
        x = tmp.index("utf")
        tmp.slice!(x..(x+9))
      end
      qp_array = tmp.split("|")
      # f = ""
      q = ""
      qp_array.each do |n|
        # if n.include?("f:")
        #   f = n.gsub("f: ","")
        # end
        if n.include?("q:")
          q = n.gsub("q: ","").gsub('"','').strip
          break
        end
      end
      tmp_array << q if q.length > 0
    end
    sorted = tmp_array.sort_by! {|i| i.downcase}
    Rails.logger.info("************************ sorted = " + sorted.inspect)
    #grouped = sorted.group_by{|e| e}.map{|k, v| [k, v.length]}.to_h
    #Rails.logger.info("************************ grouped = " + grouped.inspect)
    current = ""
    first = true
    tmp_a = []
    main_a = []
    sorted.each do |q|
      if first
        current = q
        tmp_a << q
        first = false
      else
        if q.downcase == current.downcase
          tmp_a << q
        else
          main_a.push(tmp_a)
          tmp_a = []
          current = q
          tmp_a << q
        end
      end      
    end
    main_a.each do |a|
      @queries << [a.uniq, a.size]
    end
    @queries.sort_by! {|q| -q[1]}
    @queries = @queries[0..19]
    return @queries
#     
#    if params[:reportType].present? 
#      if params[:reportType] == "usage_stats"
#        @per_page = params[:per_page].blank? ? 10 : params[:per_page].to_i
#        count = get_view_and_download_count
#        @public_usage = get_view_and_download_history(@per_page)
#        @top_navigation = build_top_navigation(@per_page, count[0].the_count)
#        @bottom_navigation = build_bottom_navigation(@per_page, count[0].the_count)
#      end
#    end
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
    
    if params[:page].present?
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
end
