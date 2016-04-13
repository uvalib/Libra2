function initPage() {
	"use strict";

	// If there is an "Additional Fields" button on the page, then show the extended fields and hide the button.
	// This is on the "Add New Work" page and the corresponding edit page.
	var additionalFieldsButton = $('a[data-toggle="collapse"][href="#extended-terms"]');
	if (additionalFieldsButton.length > 0) {
		additionalFieldsButton.click();
		additionalFieldsButton.hide();
	}
}

$(window).bind('page:change', function() {
	"use strict";
	initPage();
});
