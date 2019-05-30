(function() {
  "use strict";
  function initPage() {

    var outerForm = $(".generic_work_contributor");
    function lookup(self) {
      var index = self.data("index");
      var id = self.val();

      function onSuccess(resp) {
        console.log(resp);
        var elFirstName = outerForm.find(".contributor_first_name[data-index=" + index + "]");
        var elLastName = outerForm.find(".contributor_last_name[data-index=" + index + "]");
        var elDepartment = outerForm.find(".contributor_department[data-index=" + index + "]");
        var elDepartmentOptions = elDepartment.siblings('.department-options')
        var elInstitution = outerForm.find(".contributor_institution[data-index=" + index + "]");

        elDepartment.attr('placeholder', '')
        elDepartmentOptions.empty();

        if (resp.cid) {
          // The computing id was found if the object returned is not empty.
          elFirstName.val(resp.first_name);
          elLastName.val(resp.last_name);
          elInstitution.val(resp.institution);
          if(resp.department && resp.department.length > 1){
            elDepartment.attr('placeholder', 'Copy from below')
            var departments = "Departmental Affiliations:</br>" +
              resp.department.join('</br>')
            elDepartmentOptions.html( departments );
          } else {
            elDepartment.val(resp.department[0]);
          }
        } else {
          elFirstName.val("");
          elLastName.val("");
          elDepartment.val("");
          elInstitution.val("");
        }
        $("body").trigger("computing_id:change", { index: index });
      }

      $.ajax("/computing_id.json", {
        data: { id: id, index: index },
        success: onSuccess
      });
    }

    var body = $("body");
    body.on("keyup", ".contributor_computing_id", function() {
      var self = $(this);
      lookup(self);
    });

    body.on("change", ".contributor_computing_id", function() {
      var self = $(this);
      lookup(self);
    });
  }

  $(window).bind('turbolinks:load', function() {
    initPage();
  });
})();
