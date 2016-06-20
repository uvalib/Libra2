(function() {
	"use strict";
	function initPage() {
		// contributor_first_name, contributor_computing_id, contributor_last_name, contributor_department, contributor_institution
		// data-index
		$("body").on("change", ".contributor_computing_id, .contributor_first_name, .contributor_last_name, .contributor_department, .contributor_institution", function() {
			var el = $(this);
			var index = el.data("index");
			var contributor = $('.contributor[data-index="' + index + '"]');
			var valueArr = [];
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
		});
	}
	$(window).bind('page:change', function() {
		initPage();
	});
})();
