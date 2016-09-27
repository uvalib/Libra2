(function() {
	"use strict";
	function initPage() {

		var fileTypes = [
			"csv",
			"gif",
			"htm",
			"html",
			"jpeg",
			"jpg",
			"mov",
			"mp3",
			"mp4",
			"pdf",
			"png",
			"tif",
			"tiff",
			"txt",
			"xml"
		];

		var list = fileTypes.join(", ").toUpperCase();
		var filter = fileTypes.join("|");

		// Match any file that doesn't contain the above extensions.
		var regex = new RegExp("(\.|\/)(" + filter + ")$", "i");
		var acceptableFileTypeList = $(".acceptable-file-type-list");
		acceptableFileTypeList.text(list);

		var fileUploadButton = $('#fileupload');
		if (fileUploadButton.length > 0) { // If we are on a page with file upload.
			// Override curation_concern's file filter. We wait until we are sure that the curation_concern has initialized to make sure this gets called last.
			setTimeout(function() {
				fileUploadButton.fileupload(
					'option',
					'acceptFileTypes',
					regex
				);
			}, 1000);
		}
	}

	$(window).bind('turbolinks:load', function() {
		initPage();
	});
})();
