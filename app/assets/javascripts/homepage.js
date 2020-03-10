var homepageFunctions = {
    onLoad: function() {
		this.bindEventListeners();
	},
		
	bindEventListeners: function() {
	    $('ul.dropdown-menu li').each(function() {
            $(this).mouseover(function(e) {
        	    $(this).children('span').css("display","inline");
    		});
            $(this).mouseout(function(e) {
        	    $(this).children('span').css("display","none");
    		});
        });
	}
		
};

Blacklight.onLoad( function() {
    if ( $('body').prop('className').indexOf("homepage") ) {
	    homepageFunctions.onLoad();
    }
});
