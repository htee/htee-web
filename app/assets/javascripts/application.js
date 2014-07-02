// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap.min
//= require turbolinks
//= require_tree .

$( document ).ready(function() {
  $("pre.stream").each(function(_, obj) {
    var pre = $(obj)
    var url = pre.attr("href")
    var source = new EventSource(url)

    source.onmessage = function(e) { pre.append(JSON.parse(e.data)) }

    source.onerror = function(e) { console.log(e) }

    source.addEventListener('eof', function(e) { source.close() }, false)
  })
})
