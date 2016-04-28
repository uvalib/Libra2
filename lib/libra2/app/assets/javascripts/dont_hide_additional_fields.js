(function() {
	"use strict";

	function initPage() {

		// If there is an "Additional Fields" button on the page, then show the extended fields and hide the button.
		// This is on the "Add New Work" page and the corresponding edit page.
		var additionalFieldsButton = $('a[data-toggle="collapse"][href="#extended-terms"]');
		var externalFields = $("#extended-terms");
		if (additionalFieldsButton.length > 0) {
			if (!externalFields.hasClass("in")) // This can get called twice sometimes, so we don't want to toggle it twice.
				additionalFieldsButton.click();
			additionalFieldsButton.hide();
		}
	}

	$(window).bind('page:change', function() {
		initPage();
	});
})();