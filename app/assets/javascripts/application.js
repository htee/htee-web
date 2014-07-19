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
//= require ansi_up
//= require_tree .

var color = function(text) {
  return ansi_up.ansi_to_html(text, {use_classes: true})
}

var playbackStream = function(pre) {
  var $pre = $(pre)
  var url = $pre.attr("href")
  var source = new EventSource(url)
  var scrollLock = true
  var panel = $pre.parent().parent()

  var scrollDown = function(e) {
    if (scrollLock) {
      pre.scrollTop = pre.scrollHeight
    }
  }

  source.onmessage = function(e) {
    $pre.append(color(JSON.parse(e.data)))
    scrollDown()
  }

  source.onerror = function(e) {
    source.close()

    statusSpan = panel.find("span.status")
    statusSpan.addClass('finished')
    statusSpan.removeClass('recording')

    deleteForm = panel.find("form.delete")
    deleteForm.removeClass('invisible')
  }

  source.addEventListener('eof', function(e) { source.close() }, false)

  $pre.bind('mousewheel', function(e) {
    if (e.originalEvent.wheelDelta >= 0) {
      scrollLock = false
    } else if ($pre.scrollTop() + $pre.outerHeight() > pre.scrollHeight) {
      scrollLock = true
    }
  });
}

$( document ).ready(function() {
  $("pre.stream").each(function(_, pre) {
    playbackStream(pre)
  })

  $(".gist").each(function(_, gist) {
    var bgColor = $(gist).css("background-color")
    $(gist).find(".gist-data").css("background-color", bgColor)

    $(gist).find("pre.line-pre > .line > span").each(function(_, span) {
      $span = $(span)
      line = span.innerText

      $span.empty()

      $span.addClass("gist-line")
      $span.removeClass("go")

      $span.append(color(line))
    })
  })

  var pollCreatedStream = function(url, target) {
    $.ajax(url, {
      type: "GET",
      statusCode: {
        200: function(response) {
          stream = $.parseHTML(response)
          modal = $(target).find(".modal-content")

          modal.replaceWith(stream)

          playbackStream($(stream).find("pre")[0])

          $(target).on('hidden.bs.modal', function (e) {
            $(stream).replaceWith(modal)
          })
        },
        201: function(response) {
          setTimeout(function() { pollCreatedStream(url, target) }, 1000)
        },
      },
    })
  }

  $("#lite-stream-modal").on("show.bs.modal", function(e) {
    $.post("/", function(data) {
      $("#lite-stream-modal").find("pre")[0].innerText = "| bash <(curl -Ls " + data.scriptURL + ")"

      pollCreatedStream(data.url, $("#lite-stream-modal"))
    })
  })
})
