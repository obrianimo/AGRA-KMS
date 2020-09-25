class SearchHistoryController < ApplicationController

  require "csv"

  before_action :authenticate_user!
  before_action :authorize_admin
  with_themed_layout 'dashboard'
    
  def index
    @query_range = params[:query_range]
    queries = build_the_report(@query_range)
    @queries = queries[0..19]
    return @queries
  end

  def build_the_report(query_range)
    months_back = query_range.nil? ? 3 : query_range.to_i
    date_back = Date.today - months_back.months
    created_at = date_back.strftime('%Y-%m-%d')
    results = Searches.find_by_sql("SELECT query_params FROM searches WHERE query_params LIKE '%q:%' AND created_at > '#{created_at}';")
    queries = []
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
      queries << [a.uniq, a.size]
    end
    queries.sort_by! {|q| -q[1]}
    return queries
  end

  def download_report
    queries = build_the_report(12)
    final_qs = queries[0..99] if queries.size > 100
    final_qs = queries if queries.size < 100
    tempfile = Tempfile.new("temp_report_file_#{Time.now.strftime('%m-%d-%Y')}.csv") 
    file_name = "deposits_report_#{Time.now.strftime('%m-%d-%Y')}.csv"
    CSV.open(tempfile.path, "w") do |csv|
      csv << ["Search history, last 12 months", Date.today]
      csv <<  ["Search term", "Count"]
      final_qs.each do |q|
        csv << [q[0].join(", "), q[1]]
      end
    end
    
    send_file tempfile.path, :type => 'text',
                        :disposition => 'attachment',
                        :filename => file_name
    tempfile.close
  end

end
