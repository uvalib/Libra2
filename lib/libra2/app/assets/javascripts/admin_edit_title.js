(function() {
	"use strict";
	function initPage() {

		$(".admin-edit-title").on("click", function(ev) {
			ev.preventDefault();
			var button = $(this);
			var parent = button.closest("td");
			var title = parent.find(".title");
			var titleForm = parent.find(".title-form");
			button.hide();
			title.hide();
			titleForm.show();
		});
	}

	$(window).bind('turbolinks:load', function() {
		initPage();
	});
})();
