window.createDisplayLabel = function() {
	"use strict";
	var fileUploadSection = $("#fileupload");
	var fileList = fileUploadSection.find("tr");
	var nextIndex = fileList.length;
	var lastName = $("#generic_work_author_last_name").val();
	var firstName = $("#generic_work_author_first_name").val();
	var year = new Date().getFullYear();
	var degree = $("#generic_work_degree").val().split(" ")[0];

	return nextIndex + "_" + lastName + "_" + firstName + "_" + year + "_" + degree;
};
