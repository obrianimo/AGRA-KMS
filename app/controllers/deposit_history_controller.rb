class DepositHistoryController < ApplicationController

  require "csv"

  before_action :authenticate_user!
  before_action :authorize_admin
  with_themed_layout 'dashboard'
    
  def index
    # possible types: depositor - sort by depositor; work - sort by work; user- display for a specific user
    @query_type = params[:type].present? ? params[:type] : "depositor"
    @start_at = params[:start].present? ? params[:start] : 0
    @prev = params[:prev].present? ? params[:prev] : 0
    @email = params["email"]
    @depositors = build_user_select
    @per_page = 8 if @query_type == "depositor"
    @per_page = 15 if @query_type != "depositor"

    #@report_type = params["report_type"].present? ? params["report_type"] : "by_all_users"
    if @query_type == "user"
      solr_url = ENV["SOLR_URL"] + "/select?q=*%3A*&fl=depositor_ssim%2Csystem_create_dtsi%2Ctitle_tesim&rows=" + @per_page.to_s + "&start=" + @start_at.to_s + "&wt=json&indent=true&fq=has_model_ssim%3AGenericWork&sort=system_create_dtsi+desc&fq=depositor_ssim%3A" + params["email"]
    elsif @query_type == "work"
      solr_url = ENV["SOLR_URL"] + "/select?q=*%3A*&fq=has_model_ssim%3AGenericWork&fl=depositor_ssim%2Csystem_create_dtsi%2Ctitle_tesim&rows=2147483647&wt=json&indent=true"
    else
      solr_url = ENV["SOLR_URL"] + "/select?q=*%3A*&fq=has_model_ssim%3AGenericWork&fl=depositor_ssim%2Csystem_create_dtsi%2Ctitle_tesim&rows=2147483647&wt=json&indent=true"
    end
    url = URI.parse(solr_url)
    resp = Net::HTTP.get_response(url)
    data = resp.body
    result = JSON.parse(data)
    docs = result["response"]["docs"]
    @docs = docs.sort_by! {|d| [d['depositor_ssim'][0], d['system_create_dtsi']]} if @query_type == "depositor"
    @docs = docs.sort_by! {|d| d['title_tesim'][0]} if @query_type == "work"
    if @query_type == "user"
      @docs = docs
      if @docs.first.present?
        @last_upload = @docs.first['system_create_dtsi'].present? ? @docs.first['system_create_dtsi'][0..9] : "n/a"
      else
        @last_upload = ""
      end
    end
    @num_found = result["response"]["numFound"]
  end
  
  def build_user_select
    solr_url = ENV["SOLR_URL"] + "/select?q=*%3A*&rows=0&facet.limit=-1&wt=json&indent=true&facet=true&facet.field=depositor_ssim"
    url = URI.parse(solr_url)
    resp = Net::HTTP.get_response(url)
    data = resp.body
    result = JSON.parse(data)
    facets = result["facet_counts"]["facet_fields"]["depositor_ssim"]
    depositors = []
    facets.each do |f|
      depositors << f unless !f.is_a? String
    end
    return depositors
  end

  def download_report
    # get the data first
    solr_url = ENV["SOLR_URL"] + "/select?q=*%3A*&fq=has_model_ssim%3AGenericWork&fl=depositor_ssim%2Csystem_create_dtsi%2Ctitle_tesim&rows=2147483647&wt=json&indent=true"
    url = URI.parse(solr_url)
    resp = Net::HTTP.get_response(url)
    data = resp.body
    result = JSON.parse(data)
    raw_docs = result["response"]["docs"]
    docs = raw_docs.sort_by! {|d| d['title_tesim'][0]}
    # now build the output
    tempfile = Tempfile.new("temp_report_file_#{Time.now.strftime('%m-%d-%Y')}.csv") 
    file_name = "deposits_report_#{Time.now.strftime('%m-%d-%Y')}.csv"
    CSV.open(tempfile.path, "w") do |csv|
      csv << ["Deposits Report", Date.today]
      csv <<  ["Title", "Depositor", "Uploaded on"]
      docs.each do |d|
        csv << [d['title_tesim'][0], d['depositor_ssim'][0], d['system_create_dtsi'][0..9]]
      end
    end
    
    send_file tempfile.path, :type => 'text',
                        :disposition => 'attachment',
                        :filename => file_name
    tempfile.close
  end
end


