Blacklight.onLoad( function() {
    if ( $('body').prop('className').indexOf("collections_index") >= 0 ) {
        if ( $('div.thumbnail-wrapper').children('img').attr("src").indexOf("collection-") > 0 ) {
            $('.thumbnail-wrapper').hide();
        } 
    }
    if ( $('body').prop('className').indexOf("dashboard/collections_show") >= 0 ) {
        if ( $('.collection').children('div.text-center').children('img').attr("src").indexOf("collection-") > 0 ) {
            $('.collection').children('div.text-center').children('img').hide();
        }
    }
    if ( $('body').prop('className').indexOf("dashboard/collections_edit") >= 0 ) {
        $('div.collection_title_sort').hide();
    }
    
});
