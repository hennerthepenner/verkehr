parseValue = (samples) ->
  "<pre>" + JSON.stringify(samples, null, 2) + "</pre>"

handleData = (data) ->
  $("#no-connection").css("display", "none")
  for uuid, samples of data
    if $("##{uuid}").length
      $("##{uuid}").children(".bla").html(parseValue(samples))
    else
      $("#nodes").append(
        "<div id=\"#{uuid}\" class=\"node\">
           <h3>#{uuid}</h3>
           <div class=\"bla\">#{parseValue(samples)}</div>
         </div>"
      )

# If server gets down, don't panic, just show this fancy error message. jQuery
# is still polling the server and when he gets back, everything's fine again.
handleError = () ->
  $("#no-connection").css("display", "block")

fetchData = () ->
  # Use jQuery to poll the server regularly
  $.getJSON("/data", handleData).fail(handleError).always () ->
    setTimeout(fetchData, 1000)


$(document).ready () ->
  fetchData()
