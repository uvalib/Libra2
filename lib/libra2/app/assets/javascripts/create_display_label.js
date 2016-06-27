window.createDisplayLabel = function(file) {
	"use strict";
	var fileUploadSection = $("#fileupload");
	// only count the rows that have actual files uploaded. We tell because they have a file label input.
	var fileList = fileUploadSection.find('tr input[name="previously_uploaded_files_label[]"],tr input[name="newly_uploaded_files_label[]"]');
	var nextIndex = fileList.length + 1;
	var lastName = $("#generic_work_author_last_name").val();
	var firstName = $("#generic_work_author_first_name").val();
	var year = new Date().getFullYear();
	var degree = $("#generic_work_degree").val().split(" ")[0];
	var extension = file.name.split(".");
	extension = extension[extension.length-1];

	return nextIndex + "_" + lastName + "_" + firstName + "_" + year + "_" + degree + "." + extension;
};
