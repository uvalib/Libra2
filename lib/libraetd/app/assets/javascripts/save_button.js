(function() {
  "use strict";
  function initPage() {
    var form = $(".edit_generic_work");

    // The required fields should not keep the form from submitting.
    // Turn off the browser's required field processing, but keep the indication that the field is required, so that it can be styled.
    var required_fields = form.find("[required=required]");
    required_fields.prop("required", false);

    // Turn off the Sufia submit prevention
    // Do this in a timeout so that the sufia code will run first.
    setTimeout(function() {
      form.off("submit");
    }, 100);

    // Override the sufia code that disables the "save" button. We always want to be able to save.
    form.on('blur change keyup', 'input, select, textarea', function(){
      // Do this in a timeout so that the sufia code will run first.
      setTimeout(function() {
        setRequired();
      }, 10);
    });

    $('body').on('DOMNodeInserted','tr.template-download', function(e){
      setTimeout(function() {
        setRequired();
      }, 200);
    });

    $('body').on('managed_field:change', function(e){
      setRequired();
    });

    // Don't allow the user to submit twice, so when the button is pressed, disable it.
    // But make sure the requirement code below doesn't counteract this, so we need a flag.
    var save = $("#with_files_submit_exit,#with_files_submit_continue");
    save.on("click", function(e) {
      $(save[0]).after("<div class='save-message'>Saving. Please wait...</div>");
      save.hide();
    });

    // Override the "Add files" requirement so that it looks at previously uploaded files, too.
    var requiredFiles = $("#required-files-libra");
    var requiredMetaData = $("#required-metadata-libra");
    var fileUploadSection = $("#fileupload");
    function setRequired() {
      // include new files in required fields
      required_fields = required_fields.add($(document).find("#fileupload input.required"));

      // we can always save and exit
      $("#with_files_submit_exit").prop( "disabled", false );

      // We can only save and continue if the agreement is checked
      var save_and_continue = $("#with_files_submit_continue");
      var agreement = $("#agreement:checked");
      if (agreement.length > 0)
        save_and_continue.prop("disabled", false);
      else
        save_and_continue.prop("disabled", true);

      // Be sure there is at least one file uploaded.
      // If the fileUploadSection isn't there at all, then we aren't on the edit page, so don't do anything.
      if (fileUploadSection.length === 0)
        return;
      var fileList = fileUploadSection.find('tr input[name="previously_uploaded_files_label[]"],tr input[name="uploaded_files[][label]"]')
      var pendingFileList = $(".pending-file-label");

      if (pendingFileList.length > 0) {

        requiredFiles.removeClass("incomplete");
        requiredFiles.removeClass("complete");
        requiredFiles.addClass("pending");
      } else if (fileList.length > 0) {
        requiredFiles.removeClass("incomplete");
        requiredFiles.removeClass("pending");
        requiredFiles.addClass("complete");
      } else {
        requiredFiles.removeClass("complete");
        requiredFiles.removeClass("pending");
        requiredFiles.addClass("incomplete");
      }

      // Be sure all the metadata is filled in.
      var allFilledIn = true;
      $.each(required_fields, function(index, value) {
        var el = $(value);
        var val = el.val();
        if (val.length === 0) {
          allFilledIn = false;
          el.addClass("invalid-input");
        } else {
          el.removeClass("invalid-input");
        }
      });
      // Also be sure that the first advisor fields are filled in. We have to do this on the fly since the user can delete the first one.
      // Only first/last name are required
      var inputs = $("#contributor_contributor_first_name_0,#contributor_contributor_last_name_0");
      inputs.each(function() {
        var el = $(this);
        if (el.val().length === 0) {
          allFilledIn = false;
          el.addClass("invalid-input");
        } else {
          el.removeClass("invalid-input");
        }
      });
      if (allFilledIn) {
        requiredMetaData.removeClass("incomplete");
        requiredMetaData.addClass("complete");
      } else {
        requiredMetaData.removeClass("complete");
        requiredMetaData.addClass("incomplete");
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

    // Also if the computing id changes, recheck.
    var body = $("body");
    body.on("computing_id:change", setRequired);
    body.on("#file_display_label:change", setRequired);

    // fixed sidebar
    $('form [role="complementary"]').affix({offset: {bottom: 600, top: 300}});

  }

  $(window).bind('turbolinks:load', function() {
    initPage();
  });
})();
