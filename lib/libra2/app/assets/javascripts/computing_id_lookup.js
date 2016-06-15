(function() {
	"use strict";
	function initPage() {

		var outerForm = $(".generic_work_contributor");
		$("body").on("keyup", ".contributor_computing_id", function() {
			var self = $(this);
			var index = self.data("index");
			var id = self.val();

			function onSuccess(resp) {
				console.log(resp);
				if (resp.cid) {
					// The computing id was found if the object returned is not empty.
					var elFirstName = outerForm.find(".contributor_first_name[data-index=" + index + "]");
					elFirstName.val(resp.first_name);
					var elLastName = outerForm.find(".contributor_last_name[data-index=" + index + "]");
					elLastName.val(resp.last_name);
					var elDepartment = outerForm.find(".contributor_department[data-index=" + index + "]");
					elDepartment.val(resp.department);
					var elInstitution = outerForm.find(".contributor_institution[data-index=" + index + "]");
					elInstitution.val(resp.institution);
				}
			}
			
			$.ajax("/computing_id.json", {
				data: { id: id, index: index },
				success: onSuccess
			});
		});
	}

	$(window).bind('page:change', function() {
		initPage();
	});
})();
