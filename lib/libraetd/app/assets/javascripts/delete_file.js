(function() {
	"use strict";
	function initPage() {

		// Don't allow the enter key on the page where the edit form is present -- it defaults to trying to delete the file.
		// The exception is if the delete button is focused -- then we really do want to allow the default.
		// Also, if the control is a textarea, then the enter key is needed.
		if ($("#fileupload").length > 0) {
			$(document).keypress(function(e) {
				if (e.keyCode === 13) {
					var target = $(e.target);
					var shouldStop = true;
					if (target.hasClass("delete-previous-file"))
						shouldStop = false;
					if (e.target.nodeName === "textarea" || e.target.nodeName === "TEXTAREA")
						shouldStop = false;
					if (shouldStop) {
						e.stopPropagation();
						return false;
					}
				}
			});
		}

		$(".delete-previous-file").on("click", function(ev) {
			ev.preventDefault();
			var button = $(this);
			var parent = button.closest("tr");
			button.attr("disabled", "disabled");
			var label = parent.find('input[name="previously_uploaded_files_label[]"]');
			var td = label.closest("td");
			label.remove();
			td.html("<div class='delete-message'>Deleting file. Please wait...</div>");
			$("body").trigger("file_display_label:change", { });

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

	$(window).bind('turbolinks:load', function() {
		initPage();
	});
})();
