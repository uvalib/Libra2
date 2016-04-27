(function() {
	"use strict";
	function initPage() {

		// If this is the page that gets a preview button, then add that button if it is not already present.
		if ($("#preview-work").length === 0) {
			var url = '' + window.location.pathname;
			url = url.split("/");
			// Put the preview button on the page that looks like "/concern/generic_works/:id"
			if (url.length === 4 && url[0] === '' && url[1] === 'concern' && url[2] === 'generic_works') {
				var container = $(".show-actions");
				if (container.length === 1) {
					container.append('<a class="btn btn-default" href="/preview/' + url[3] + '">Next</a>')
				}
			}
		}
	}

	$(window).bind('page:change', function() {
		initPage();
	});
})();
