(function() {
	"use strict";
	function initPage() {

		// The thumbnail images on the show page are links, but the links aren't correct, so remove the links.
		// The html looks something like the following, but it varies depending on the type of media it is:
		// <a target="_new" title="Download the full-sized PDF" href="/downloads/xxxxxxxxxx">
		// 		<figure>
		// 		<img class="img-responsive" alt="Download the full-sized PDF of zzzzzzzzzz.pdf" src="/downloads/xxxxxxxxxx?file=thumbnail">
		// 		<figcaption>Download the full-sized PDF</figcaption>
		// 	</figure>
		// 	</a>
		var downloadArea = $('.thesis-thumbnail');
		if (downloadArea.length > 0) {// If we are on the show page.
			var links = downloadArea.find("a");
			links.removeAttr("href");
			links.removeAttr("title");
			links.removeAttr("target");
			var captions = downloadArea.find("figcaption");
			captions.remove();
		}
	}

	$(window).bind('page:change', function() {
		initPage();
	});
})();
