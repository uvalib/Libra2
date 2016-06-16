(function() {
	"use strict";
	function initPage() {

		function multiFieldAdded(ev, parent) {
			// See if the type of multifield is the Advisor.
			var target = $(parent).closest(".generic_work_contributor");
			if (target.length > 0) {
				// Either the Add or Remove button was clicked for the Advisor fields.
				var blocks = target.find("li");
				for (var i = 0; i < blocks.length; i++) {
					var block = $(blocks[i]);
					var div = block.find(".computing_id");
					var label = div.find("label");
					var input = div.find("input");
					label.attr("for", "contributor_computing_id_" + i);
					input[0].id = "contributor_computing_id_" + i;
					input.attr("data-index", i);

					div = block.find(".name_first");
					label = div.find("label");
					input = div.find("input");
					label.attr("for", "generic_work_contributor_first_name_" + i);
					input[0].id = "generic_work_contributor_first_name_" + i;
					input.attr("data-index", i);

					div = block.find(".name_last");
					label = div.find("label");
					input = div.find("input");
					label.attr("for", "generic_work_contributor_last_name_" + i);
					input[0].id = "generic_work_contributor_last_name_" + i;
					input.attr("data-index", i);

					div = block.find(".department");
					label = div.find("label");
					input = div.find("input");
					label.attr("for", "contributor_department_" + i);
					input[0].id = "contributor_department_" + i;
					input.attr("data-index", i);

					div = block.find(".affiliation");
					label = div.find("label");
					input = div.find("input");
					label.attr("for", "contributor_institution_" + i);
					input[0].id = "contributor_institution_" + i;
					input.attr("data-index", i);
				}
			}
		}
		$("body").on("managed_field:change", multiFieldAdded);
	}

	$(window).bind('page:change', function() {
		initPage();
	});
})();

