(function() {
	"use strict";
	function initPage() {

		// Override the sufia code that disables the "save" button. We always want to be able to save.
		$(".edit_generic_work").on('blur change', 'input, select, textarea', function(){
			// Do this in a timeout so that the sufia code will run first.
			setTimeout(function() {
				var save = $("#with_files_submit");
				save.prop("disabled", false);
			}, 10);
		});
	}

	$(window).bind('page:change', function() {
		initPage();
	});
})();
