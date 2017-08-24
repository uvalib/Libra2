Polymer = {dom: 'shadow'};

(function() {
  if ('registerElement' in document
      && 'import' in document.createElement('link')
    && 'content' in document.createElement('template')) {
      // platform is good!
    } else {
      document.write( '<script src="//www.library.virginia.edu/wp-content/themes/libweb/bower_components/webcomponentsjs/webcomponents-lite.js"></script>')
    }
})();
