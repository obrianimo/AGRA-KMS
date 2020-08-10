var depositHistory = {
    onLoad: function() {
		this.bindEventListeners();
	},
	
	bindEventListeners: function(target) {
		$('#report_type').change(function() {
		    var optionSelected = $("option:selected", this);
            var valueSelected = this.value;
			if ( valueSelected == "by_user") {
                $('#email').val($("#email option:first").val());
                $('span#select_user').show();
                $("select#email").focus();
			}
			else if ( valueSelected == "by_all_users") {
			    $('form#dep_history_form').attr("action","/deposit_history/depositor/");
			    $('#email').val($("#email option:first").val());
			    $('form#dep_history_form').submit();
			}
			else if ( valueSelected == "by_title") {
			    $('form#dep_history_form').attr("action","/deposit_history/work/");
			    $('#email').val($("#email option:first").val());
			    $('form#dep_history_form').submit();
			}
		});
		$('#email').change(function() {
		    var optionSelected = $("option:selected", this);
            var valueSelected = this.value;
			if ( valueSelected != "") {
                var input = $("<input>")
                               .attr("type", "hidden")
                               .attr("name", "email").val(valueSelected);
                $('form#dep_history_form').append(input);
			    $('form#dep_history_form').submit();
			}
		});
	}
};

Blacklight.onLoad( function() {
    if ( $('body').prop('className').indexOf("deposit_history") >= 0 ) {
        depositHistory.onLoad();  
    }
});
