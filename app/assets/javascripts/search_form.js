var setupSearchFormAjax = {
    onLoad: function() {
		this.bindEventListeners();
	},
	
	// Ajax call in bindEventListeners will not work with a url that uses local host.
	// So stitch a useable url.
    getFrankensteinSolrUrl: function() {
        var clean_solr_url = "";
        if ( solr_url.indexOf("localhost") >= 0 ) {
            var tmp1 = rails_root.substring(0, rails_root.indexOf("/?locale"));
            var tmp2 = solr_url.substring(solr_url.lastIndexOf("localhost:") + 9, solr_url.length);
            clean_solr_url = tmp1 + tmp2;
    		return clean_solr_url;
        }
        else {
            return solr_url;
        }
    },
    
	bindEventListeners: function() {
      $('input.q').each(function() {
        $(this).autocomplete({
          minLength: 3,
          source: function(request, response) {
            $.ajax({
              url: setupSearchFormAjax.getFrankensteinSolrUrl() + '/select?q=*%3A*&fq=has_model_ssim%3AGenericWork&rows=0&fl=*&wt=json&indent=true&facet=true&facet.field=value_chain_sim&facet.field=based_near_sim&facet.field=keyword_sim&facet.field=commodities_sim&facet.field=subject_sim',
		      type: 'GET',
              dataType: 'jsonp',
		      jsonp : 'json.wrf',
	          complete: function(data) {
	            facets = data['responseJSON']['facet_counts']['facet_fields'];
	            values = [];
		        $.map(facets, function(value) {
		          $.each(value, function() {
		            if ( !$.isNumeric(this) && this.toLowerCase().indexOf(request.term.toLowerCase()) >= 0 ) {
		                values.push(this.toString());
		            }
		          });
		        }); 
		        values.sort();
	            response(values);
	          }
	        });
	      }
	    });
      });
	}	
};

Blacklight.onLoad( function() {
    if ( $('input.q').length ) {
	    setupSearchFormAjax.onLoad();
    }
});
