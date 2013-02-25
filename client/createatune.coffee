
Template.createatune.rendered = ->
  tabDiv = new Vex.Flow.TabDiv($(".vex-tabdiv"))
  $(".vex-tabdiv p").remove()
  editor = CodeMirror.fromTextArea(document.getElementById("notes-editor"), {})
  hlLine = editor.addLineClass(0, "background", "activeline")
  editor.on "cursorActivity", RedrawTab

  #Event Handlers
  editor.focus()
  $(".CodeMirror").on "click", ->
    editor.focus()

  $(".picker-menu .dropdown-menu a").click ->
    $this = $(this)
    idName = $this.parent().parent().attr("aria-labelledby")
    tuneTab.config[idName] = $this.attr("rel")
    aria = $("#" + idName)
    aria.html aria.find("i")[0].outerHTML + " " + _(tuneTab.config[idName]).capitalize() + " <span class=\"caret\"></span>"
    aria.attr "rel", tuneTab.config[idName]
    if idName is "tempo"
      u.getUnity().SendMessage "BrowserProxy", "SetBPM", tuneTab.config.tempo
    RedrawTab()

  $("#play").click Play

  $(".save-midi").click ->
    file = GetMidiFileFromTab()

    window.open "data:audio/midi;base64," + $.base64.encode(file.toBytes()), "", "resizable=yes,scrollbars=no,status=no"
    ###
    if document
      embed = document.createElement "embed"
      embed.setAttribute "src", "data:audio/midi;base64," + $.base64.encode(file.toBytes())
      embed.setAttribute "type", "audio/midi"
      document.body.appendChild embed
    ###
    return false

  $(".import-midi").click ->
    if editor.getValue().trim() isnt ""
      bootbox.confirm "Editor will be overriden. Are you sure you want to continue?", (result) ->
        log result
    return false

  tuneTab.config.tabType = $("#tabType").attr("rel")
  tuneTab.config.tempo = parseInt $("#tempo").attr("rel")
  RedrawTab()

  #Unity
  config =
    width: 940
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
        u.getUnity().SendMessage "BrowserProxy", "SetBPM", tuneTab.config.tempo+""
  
  $unityPlayer = jQuery("#unity-player")[0];
  if $unityPlayer
    u.initPlugin $unityPlayer, "/synth/maple.unity3d"
  else
    UnityFallback()

#this happens before anything is rendered
global.pageInits.createatune = ->
  filepicker.setKey "ARqlFQ50RUO185W0sdSY0z"
  unless Meteor.userId()
    Meteor.Router.navigate "",
      trigger: true
    return
###
Play = ->
  file = GetMidiFileFromTab()

  if tuneTab.config.unityStatus is "first"
    u.getUnity().SendMessage("BrowserProxy", "PlayBase64Midi", $.base64.encode(file.toBytes()));
  else if tuneTab.config.midiJsStatus is "loaded"
    player = MIDI.Player
    player.timeWarp = 120.0 / tuneTab.config.tempo
    player.loadFile "data:audio/midi;base64,"+$.base64.encode(file.toBytes()), player.start
  #player.addListener (data) ->
  #  log data
  log $.base64.encode file.toBytes()

GetMidiFileFromTab = ->
  staves = tabDiv.artist.staves
  if staves.length is 0
    return
  tracks = []
  if tuneTab.config.tabType isnt "grand"
    tracks.push tuneTab.getMidiTrackFromStaves staves
  else
    tracks.push tuneTab.getMidiTrackFromStaves staves.filter (x, i) -> i % 2 == 0
    tracks.push tuneTab.getMidiTrackFromStaves staves.filter (x, i) -> i % 2 == 1
  file = new Midi.File
  file.addTrack track for track in tracks
  file

UnityFallback = ->
  #MIDI.loader = new widgets.Loader
  MIDI.loadPlugin
    instruments: ["acoustic_grand_piano"]
    callback: ->
      #MIDI.loader.stop()
      MIDI.programChange 0, 0
      MIDI.programChange 1, 118
      tuneTab.config.midiJsStatus = "loaded"
      log "instruments loaded"