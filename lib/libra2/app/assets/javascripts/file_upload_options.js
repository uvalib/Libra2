(function() {
	"use strict";
	function initPage() {

		var fileTypes = [ "ACCDB", "ADE", "ADP", "BAT", "CHM", "CMD", "COM", "CPL", "DOC", "DOCM", "DOCX", "EXE", "GZ",
			"HTA", "INS", "ISP", "JAR", "JSE", "LIB", "LNK", "MDE", "MSC", "MSP", "MST", "PIF",
			"ODS", "OTS", "ODT", "OTT", "ODP", "OTP", "ODG", "OTG", "PPT", "PPTM", "PPTX", "PUB", "RAR",
			"SCR", "SCT", "SHB", "SYS", "TAR", "TGZ", "VB", "VBE", "VBS", "VXD", "WSC", "WSF", "WSH", "XLS", "XLSM", "XLSX", "ZIP" ];
	// 	suffixless

		var list = fileTypes.join(", ").toUpperCase();
		var filter = fileTypes.join("|!");
		// Match any file that doesn't contain the above extensions.
		//var regex = new RegExp("(\.|\/)((?!(" + filter + ")).)*$", "i");
		var regex = new RegExp("(\.|\/)((?!ODT).)*$", "i");
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

	$(window).bind('page:change', function() {
		initPage();
	});
})();
