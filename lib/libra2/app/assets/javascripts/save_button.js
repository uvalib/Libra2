(function() {
	"use strict";
	function initPage() {
		// The required fields should not keep the form from submitting.
		// Turn off the browser's required field processing, but keep the indication that the field is required, so that it can be styled.
		var required_fields = $(".edit_generic_work [required=required]");
		required_fields.prop("required", false);
		required_fields.addClass("edit-required-field");

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
				setRequired();
			}, 10);
		});

		// Override the "Add files" requirement so that it looks at previously uploaded files, too.
		var requiredFiles = $("#required-files");
		var requiredMetaData = $("#required-metadata");
		var fileUploadSection = $("#fileupload");
		function setRequired() {
			var save = $("#with_files_submit_exit,#with_files_submit_continue,#with_files_submit");

			// Be sure the agreement is set.
			var agreement = $("#agreement:checked");
			if (agreement.length > 0)
				save.prop("disabled", false);
			else
				save.prop("disabled", true);

			// Be sure there is at least one file uploaded.
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

			// Be sure all the metadata is filled in.
			var allFilledIn = true;
			$.each(required_fields, function(index, value) {
				var val = $(value).val();
				if (val.length === 0)
					allFilledIn = false;
			});
			if (allFilledIn) {
				requiredFiles.removeClass("incomplete");
				requiredFiles.addClass("complete");
			} else {
				requiredFiles.removeClass("complete");
				requiredFiles.addClass("incomplete");
			}

		}
		// Do this in a timeout so that the sufia code will run first.
		setTimeout(function() {
			setRequired();
		}, 10);

		// Also recheck the file requirement when the file delete button is pressed.
		fileUploadSection.on("click", ".delete", function() {
			// Do this in a timeout so that the delete action will run first. The item fades out with a css transform, so the timeout needs to be longer than the transform.
			setTimeout(function() {
				setRequired();
			}, 2000);
		});
	}

	$(window).bind('page:change', function() {
		initPage();
	});
})();
