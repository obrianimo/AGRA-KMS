var manageWorkMetadata = {
    onLoad: function() {
		this.delayTheSetEventCall();
		this.setInitialLanguageAutocomplete();
	},
	
	delayTheSetEventCall: function() {
		setTimeout(function() {
			manageWorkMetadata.setEventOnAddButton("all")
		}, 500);
	},
	
	setEventOnAddButton: function(target) {
		$('button.add').each(function() {
			if ( target == "based_near" || target == "all" ) {
				if ( $(this).closest('div').attr('class').indexOf('generic_work_based_near') >= 0 ) {
					$(this).click(function() {
						setTimeout(manageWorkMetadata.initLanguageAutocomplete,500);
					})
				}
			}
		})
	},
	
	initLanguageAutocomplete: function() {
		$('input.generic_work_based_near').each(function() {
			$(this).autocomplete({
        		minLength: 3,
        		source: function(request, response) {
            		$.ajax({
                		url: '/authorities/search/local/geo_locations?q=' + request.term,
						type: 'GET',
                		dataType: 'json',
                		complete: function(xhr, status) {
                    		var results = $.parseJSON(xhr.responseText);                        
                    		response(results);
                		}
            		});
        		}
			})
    	})
		manageWorkMetadata.setEventOnAddButton("based_near");
	},
		
	setInitialLanguageAutocomplete: function() {
		$('input.generic_work_based_near').each(function() {
			$(this).autocomplete({
	        	minLength: 3,
	        	source: function(request, response) {
	            	$.ajax({
	                	url: '/authorities/search/local/geo_locations?q=' + request.term,
						type: 'GET',
	                	dataType: 'json',
	                	complete: function(xhr, status) {
	                    	var results = $.parseJSON(xhr.responseText);                        
	                    	response(results);
	                	}
	            	});
	        	}
		    })
	    })
	}

};

var setDownloadsLink = {
  onLoad: function() {
      workId = $(location).attr("href").split('/').pop();
      if ( workId.indexOf("?") > -1 ) {
          workId = workId.substring(0,workId.indexOf("?"));
      }
      newHref = $('a#file_download').attr('href').replace("downloads","file_downloads");
      //if ( newHref.indexOf("?") > -1 ) {
      //    newHref += "&workid=" + workId;
      //}
      //else {
      //    newHref += "?workid=" + workId
      //}
      $('a#file_download').attr("href",newHref);
  }
};

Blacklight.onLoad( function() {
    if ( $('body').prop('className').indexOf("generic_works_show") >= 0 ) {
        setDownloadsLink.onLoad();  
    }
    if ( $('body').prop('className').indexOf("generic_works_new") >= 0 ) {
        manageWorkMetadata.onLoad();  
    }
    if ( $('body').prop('className').indexOf("generic_works_edit") >= 0 ) {
        manageWorkMetadata.onLoad();  
    }
});
