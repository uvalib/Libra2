(function() {
	"use strict";
	function initPage() {
		function updateContributorField( ) {

			var index = 0;
			$( '.contributor_computing_id' ).each( function( ){
                var contributor = $('.contributor[data-index="' + index + '"]');
                var valueArr = [];
                valueArr.push( index );
                var input = $('.contributor_computing_id[data-index="' + index + '"]');
                valueArr.push(input.val());
                input = $('.contributor_first_name[data-index="' + index + '"]');
                valueArr.push(input.val());
                input = $('.contributor_last_name[data-index="' + index + '"]');
                valueArr.push(input.val());
                input = $('.contributor_department[data-index="' + index + '"]');
                valueArr.push(input.val());
                input = $('.contributor_institution[data-index="' + index + '"]');
                valueArr.push(input.val());
                contributor.val(valueArr.join("\n"));
                index++;
            });
		}

		var body = $("body");
		body.on("change", ".contributor_computing_id, .contributor_first_name, .contributor_last_name, .contributor_department, .contributor_institution", function() {
			updateContributorField( );
		});

		body.on("computing_id:change", function(ev, params) {
			updateContributorField(params.index);
		});
	}
	$(window).bind('turbolinks:load', function() {
		initPage();
	});
})();
