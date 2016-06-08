(function() {
	"use strict";
	function initPage() {

		// Select the activity tab by default in the profile page, because the default tab (Highlight) is now hidden.
		var activityTab = $('.profile .nav-tabs a[href="#activity_log"]');
		if (activityTab.length > 0)
			activityTab.tab('show');

		var editField = $("#representative-media");
		if (editField.length > 0)
			editField.remove();
		editField = $("#representative-image");
		if (editField.length > 0)
			editField.remove();
	}

	$(window).bind('page:change', function() {
		initPage();
	});
})();
