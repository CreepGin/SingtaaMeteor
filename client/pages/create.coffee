testJson = [
  bpm: 120
  beat: 4
  noteGroups: [
    duration: 4
    type: "note"
    keys: [pitch: 44]
  ,
    duration: 4
    type: "note"
    keys: [
      pitch: 60
    ,
      pitch: 64
    ,
      pitch: 67
    ]
  ]
]

tuneTab = new TuneTab()
timeoutID = undefined
editor = undefined
hlLine = undefined
tabDiv = undefined
u = undefined

Template.create.rendered = ->
  #module Handling
  $( ".sortable" ).sortable()
  $(".module-controls li").each ->
    _swapModuleControlAlign this, $(this).attr("data-align")

  #Unity
  config =
    width: 780
    height: 400,
    params:
      enableDebugging:"0"
  u = new UnityObject2 config

  u.observeProgress (progress) ->
    tuneTab.config.unityStatus = progress.pluginStatus
    switch progress.pluginStatus
      when "missing", "broken"
        UnityFallback()
      when "first"
        ""
  
  unityPlayer = jQuery(".unity-player")[0];
  if unityPlayer
    u.initPlugin unityPlayer, "/synth/SingtaaPlayer.unity3d"
  else
    UnityFallback()

  #Vexflow
  tabDiv = new Vex.Flow.TabDiv($(".vex-tabdiv"))
  $(".vex-tabdiv p").remove()
  editor = CodeMirror.fromTextArea(document.getElementById("notes-editor"), {})
  hlLine = editor.addLineClass(0, "background", "activeline")
  editor.on "cursorActivity", RedrawTab
  editor.focus()
  $(".CodeMirror").on "click", ->
    editor.focus()

  #Editor
  tuneTab.config.tabType = $("#tabType").attr("rel")
  tuneTab.config.tempo = parseInt $("#tempo").attr("rel")
  tuneTab.config.beat = parseInt $("#beat").attr("rel")
  $(".picker-menu .dropdown-menu a").click ->
    $this = $(this)
    text = $this.text()
    idName = $this.parent().parent().attr("aria-labelledby")
    tuneTab.config[idName] = $this.attr("rel")
    aria = $("#" + idName)
    aria.html aria.find("i")[0].outerHTML + " " + text + " <span class=\"caret\"></span>"
    aria.attr "rel", tuneTab.config[idName]
    RedrawTab()
  $("#play").click Play


#Sort change handler
$(document).on "sortstop", ".sortable", (e) ->
  _refreshModules()

#Module Control list item click handler
$(document).on "click", ".module-controls li", (e) ->
  align = $(this).attr("data-align")
  _swapModuleControlAlign this, if align is "left" then "right" else "left"

#Module Control list item Thumb square click handler
$(document).on "click", ".module-controls li .thumb", (e) ->
  e.preventDefault()
  e.stopPropagation()
  enabled = $(this).parent().attr("data-enabled")
  $(this).parent().attr "data-enabled", if enabled is "true" then "false" else "true"
  _refreshModules()

Play = ->
  staves = tabDiv.artist.staves
  if staves.length is 0
    return
  tracks = []
  if tuneTab.config.tabType isnt "grand"
    tracks.push tuneTab.getTrackFromStaves staves
  else
    tracks.push tuneTab.getTrackFromStaves staves.filter (x, i) -> i % 2 == 0
    tracks.push tuneTab.getTrackFromStaves staves.filter (x, i) -> i % 2 == 1
  log tracks
  if tuneTab.config.unityStatus is "first"
    u.getUnity().SendMessage("BrowserProxy", "PlayTracks", JSON.stringify(tracks));


RedrawTab = ->
  that = this
  window.clearTimeout timeoutID  if timeoutID
  timeoutID = window.setTimeout(->
    
    # Draw only if code changed
    transformedCode = tuneTab.transformCode(GetCodeInCurrentPage())
    unless tabDiv.code is transformedCode
      tabDiv.code = transformedCode
      tabDiv.redraw()
  , 200)
  
  #Editor Line Highlighting
  cur = editor.getLineHandle(editor.getCursor().line)
  unless cur is hlLine
    editor.removeLineClass hlLine, "background", "activeline"
    hlLine = editor.addLineClass(cur, "background", "activeline")

GetCodeInCurrentPage = ->
  selection = editor.getSelection()
  return selection  if selection isnt ""
  allLines = editor.getValue().split("\n")
  cursorLine = editor.getCursor().line
  newLines = []
  i = cursorLine - 1

  while i >= 0
    line = allLines[i].trim()
    break  if _(line).startsWith("---")
    newLines.unshift line
    i--
  j = cursorLine

  while j < allLines.length
    line = allLines[j].trim()
    break  if _(line).startsWith("---")
    newLines.push line
    j++
  newLines.join "\n"

_swapModuleControlAlign = (t, newAlign) ->
  firstSpanIsThumb = $(t).find("span").first().hasClass "thumb"
  if newAlign is "right" and firstSpanIsThumb or newAlign is "left" and not firstSpanIsThumb
    $(t).append $(t).find("span").first()
  $(t).attr "data-align", newAlign
  $(t).css "text-align", newAlign
  _refreshModules()

_refreshModules = ->
  $(".module-controls li").each ->
    enabled = $(this).attr("data-enabled") == "true"
    align = $(this).attr("data-align")
    moduleName = $(this).attr("data-module-name")
    module = $(".modules-container").find("div[data-module-name='#{moduleName}']").first()
    $(".modules-container .#{align}-block").append module
    module.css "display", if enabled then "block" else "none"
  tabDiv.redraw() if tabDiv

UnityFallback = ->
  ""


