(function() {
	"use strict";
	function initPage() {

		// Select the activity tab by default in the profile page, because the default tab (Highlight) is now hidden.
		var activityTab = $('.profile .nav-tabs a[href="#activity_log"]');
		if (activityTab.length > 0)
			activityTab.tab('show');
	}

	$(window).bind('page:change', function() {
		initPage();
	});
})();
