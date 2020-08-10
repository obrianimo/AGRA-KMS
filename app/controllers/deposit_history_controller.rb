class DepositHistoryController < ApplicationController

  require "csv"

  before_action :authenticate_user!
  before_action :authorize_admin
  with_themed_layout 'dashboard'
    
  def index
    # possible types: depositor - sort by depositor; work - sort by work; user- display for a specific user
    @per_page = 8
    @query_type = params[:type].present? ? params[:type] : "depositor"
    @start_at = params[:start].present? ? params[:start] : 0
    @prev = params[:prev].present? ? params[:prev] : 0
    @email = params["email"]
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
    @docs = docs if @query_type == "user"
    @last_upload = @docs.first['system_create_dtsi'][0..9] if @query_type == "user"
    @num_found = result["response"]["numFound"]
  end

end


