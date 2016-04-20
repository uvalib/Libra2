(function() {
	"use strict";

	function initPage() {
		$("body").on("change", "#net-badge-ids", function() {
			var user = $("#net-badge-ids").val();
			window.location = "/development_login?user="+user;
		});
	}

	$(window).bind('page:change', function() {
		initPage();
	});
})();


