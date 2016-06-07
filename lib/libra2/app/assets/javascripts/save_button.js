(function() {
	"use strict";
	function initPage() {
		// The required fields should not keep the form from submitting.
		var required_fields = $(".edit_generic_work [required=required]");
		required_fields.prop("required", false);

		// Turn off the Sufia submit prevention
		// Do this in a timeout so that the sufia code will run first.
		setTimeout(function() {
			var form = $(".edit_generic_work");
			form.off("submit");
		}, 10);

		// Override the sufia code that disables the "save" button. We always want to be able to save.
		$(".edit_generic_work").on('blur change', 'input, select, textarea', function(){
			// Do this in a timeout so that the sufia code will run first.
			setTimeout(function() {
				var save = $("#with_files_submit");
				save.prop("disabled", false);
				setRequiredFiles();
			}, 10);
		});

		// Override the "Add files" requirement so that it looks at previously uploaded files, too.
		var requiredFiles = $("#required-files");
		var fileUploadSection = $("#fileupload");
		function setRequiredFiles() {
			// If the fileUploadSection isn't there at all, then we aren't on the edit page, so don't do anything.
			if (fileUploadSection.length === 0)
				return;
			var fileList = fileUploadSection.find("tr");
			if (fileList.length > 0) {
				requiredFiles.removeClass("incomplete");
				requiredFiles.addClass("complete");
			} else {
				requiredFiles.removeClass("complete");
				requiredFiles.addClass("incomplete");
			}
		}
		// Do this in a timeout so that the sufia code will run first.
		setTimeout(function() {
			setRequiredFiles();
		}, 10);

		// Also recheck the file requirement when the file delete button is pressed.
		fileUploadSection.on("click", ".delete", function() {
			// Do this in a timeout so that the delete action will run first. The item fades out with a css transform, so the timeout needs to be longer than the transform.
			setTimeout(function() {
				setRequiredFiles();
			}, 2000);
		});
	}

	$(window).bind('page:change', function() {
		initPage();
	});
})();
