(function() {
	"use strict";
	function initPage() {

		$(".delete-previous-file").on("click", function(ev) {
			ev.preventDefault();
			var button = $(this);
			var parent = button.closest("tr");
			button.attr("disabled", "disabled");
			var label = parent.find('input[name="previously_uploaded_files_label[]"]');
			var td = label.closest("td");
			label.remove();
			td.html("<div class='delete-message'>Deleting file. Please wait...</div>");

			function onSuccess(responseObject, status, response) {
				var id = responseObject.id;
				var tr = $("tr[data-file-id=" + id + "]");
				tr.remove();
			}
			function onError(responseObject, status, error) {
				console.log("File delete error:",responseObject, status, error);
			}
			var url = button.data("url");
			$.ajax(url, {
				method: "DELETE",
				success: onSuccess,
				error: onError
			});
		});
	}

	$(window).bind('page:change', function() {
		initPage();
	});
})();
