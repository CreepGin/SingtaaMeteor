class @ModMan

  @unity: undefined   #Unity Object
  @tabDiv: undefined  #VexFlow
  @editor: undefined  #CodeMirror Editor
  @vexMan: undefined

  @config:
    tabType: "tab"
    tempo: 120
    beat: 4
    unityStatus: "unloaded"

  @_timeoutID: undefined
  @_enableRedrawing: true

  @menuEvents: 
    "click .picker-menu .dropdown-menu a": (event) ->
      $this = $(event.target)
      text = $this.text()
      idName = $this.parent().parent().attr("aria-labelledby")
      rel = $this.attr("rel")
      if idName is "tabType" and ModMan.config.unityStatus is "first"
        if rel is "tab"
          ModMan.unity.getUnity().SendMessage("BrowserProxy", "LoadInstrument", "Guitar");
        else
          ModMan.unity.getUnity().SendMessage("BrowserProxy", "LoadInstrument", "Piano");
      ModMan.config[idName] = rel
      aria = $("#" + idName)
      aria.html aria.find("i")[0].outerHTML + " " + text + " <span class=\"caret\"></span>"
      aria.attr "rel", ModMan.config[idName]
      ModMan.redrawTab()
    "click .convert-xml": (event) ->
      $('#myModal').modal()
      $('#myModal .btn-main').off("click").on "click", ->
        xml = $("#modal-textarea").val()
        res = ScoreMan.convertMusicXML xml
        if res is ""
          alert t "Please paste in a valid MusicXML text"
          return
        textPages = _.map res.split("---"), (n) ->
          n.trim()
        ModMan.vexMan.init textPages
        ModMan.updateEditor()
        ModMan.redrawTab()
        $('#myModal').modal('hide')
        $("#modal-textarea").val("")
      Meteor.setTimeout ->
        $('#modal-textarea').focus()
      , 1000
    "click #play": (event) ->
      ModMan.play()
    "click .score .icon-chevron-left": (event) ->
      ModMan.vexMan.prev(ModMan.editor.getValue())
      ModMan.updateEditor()
      ModMan.redrawTab()
    "click .score .icon-chevron-right": (event) ->
      ModMan.vexMan.next(ModMan.editor.getValue())
      ModMan.updateEditor()
      ModMan.redrawTab()
    "click .score .add": (event) ->
      ModMan.vexMan.addPage(ModMan.editor.getValue())
      ModMan.updateEditor()
    "click .score .del": (event) ->
      ModMan.vexMan.deletePage()
      ModMan.updateEditor()
    "click .unity-controls .reload": (event) ->
      #$(".unity-player embed").css("display", "none")
      $(".unity-player embed").remove()
      Meteor.setTimeout ->
        #$(".unity-player embed").css("display", "block")
        ModMan.setupUnity()
      , 200
    "click .unity-player .install": (event) ->
      ModMan.unity.installPlugin()
    "click .controls .save": (event) ->
      ModMan.vexMan.saveCurrentText(ModMan.editor.getValue())
      data = 
        title: $("#title").val()
        description: $("#description").val()
        tags: _.map($("#tags").val().split(","), $.trim).filter((e) ->  e)
        score:
          textPages: ModMan.vexMan.textPages
          tabType: ModMan.config.tabType
          tempo: parseInt ModMan.config.tempo
          beat: parseInt ModMan.config.beat
        public: $("#public").is(':checked')
      log data
      myScoreId = Session.get("myScoreId")
      data.id = myScoreId if myScoreId
      Meteor.call "saveScore", data, (error, id) ->
        if error
          Session.set "msg", 
            type: "error"
            text: error.reason
        else
          if window.location.pathname.length < 9
            Meteor.Router.to('/compose/'+id);
          Session.set "msg", 
            type: "success"
            text: "Your score was saved!"

  @tickMenu: (ele) ->
    ModMan.menuEvents["click .picker-menu .dropdown-menu a"]({target:ele}) if ele

  @setupUnity: ->
    if $(".unity-player embed").length > 0
      return
    ModMan.unity = new UnityObject2
      width: 780
      height: 400,
      params:
        enableDebugging:"0"
    ModMan.observeUnity()
    unityPlayer = $(".unity-player")[0];
    if unityPlayer
      ModMan.unity.initPlugin unityPlayer, "/synth/SingtaaPlayer.unity3d"

  @setupVexFlow: ->
    if $(".vex-tabdiv .vex-canvas").length > 0
      return
    #ModMan.tabDiv = new Vex.Flow.TabDiv($(".vex-tabdiv"))
    ModMan.vexMan = new VexMan $(".score")
    $('.has-title').tooltip
      container: "body"
    $('.switch:not(.done)')['switch']()
    $('.switch').addClass("done")
    $('.score .switch').off("switch-change").on 'switch-change', (e, data) ->
      #$el = $(data.el)
      #value = data.value
      #console.log(e, $el, value);
      ModMan._enableRedrawing = data.value

  @updateEditor = ->
    $(".score .current-page").text(ModMan.vexMan.index)
    $(".score .max-pages").text(ModMan.vexMan.max)
    ModMan.editor.setValue ModMan.vexMan.currentTextPage

  @setupEditor: ->
    if $(".CodeMirror").length > 0
      return
    ModMan.editor = CodeMirror.fromTextArea(document.getElementById("notes-editor"), {})
    hlLine = ModMan.editor.addLineClass(0, "background", "activeline")
    ModMan.editor.on "cursorActivity", ModMan.redrawTab
    ModMan.editor.focus()
    $(".CodeMirror").on "click", ->
      ModMan.editor.focus()
    $(".CodeMirror").resizable
      stop: ->
        ModMan.editor.refresh()
      resize: ->
        $(".CodeMirror-scroll").height($(this).height())
        $(".CodeMirror-scroll").width($(this).width())
        ModMan.editor.refresh()
    ModMan.config.tabType = $("#tabType").attr("rel")
    ModMan.config.tempo = parseInt $("#tempo").attr("rel")
    ModMan.config.beat = parseInt $("#beat").attr("rel")

    ModMan.editor.focus()

  @observeUnity: ->
    ModMan.unity.observeProgress (progress) ->
      #log progress.pluginStatus
      ModMan.config.unityStatus = progress.pluginStatus
      switch progress.pluginStatus
        when "missing", "broken"
          $(".unity-player").html($(".broken-unity").clone())
          $(".unity-player .broken-unity").removeClass("hidden")
          ""
        when "first"
          Meteor.setTimeout ->
            if ModMan.config.tabType is "tab"
              ModMan.unity.getUnity().SendMessage("BrowserProxy", "LoadInstrument", "Guitar");
            else
              ModMan.unity.getUnity().SendMessage("BrowserProxy", "LoadInstrument", "Piano");
          , 2000
          ""

  @play: ->
    staves = ModMan.vexMan.currentPage.artist.staves
    if staves.length is 0
      return
    tracks = []
    tempo = ModMan.config.tempo
    beat = ModMan.config.beat
    if ModMan.config.tabType isnt "grand"
      tracks.push ScoreMan.getTrackFromStaves staves, tempo, beat
    else
      tracks.push ScoreMan.getTrackFromStaves((staves.filter (x, i) -> i % 2 == 0), tempo, beat)
      tracks.push ScoreMan.getTrackFromStaves((staves.filter (x, i) -> i % 2 == 1), tempo, beat)
    log tracks
    if ModMan.config.unityStatus is "first"
      jsonStr = JSON.stringify(tracks)
      log jsonStr
      ModMan.unity.getUnity().SendMessage("BrowserProxy", "PlayTracks", jsonStr);

  @redrawTab: ->
    if ModMan._enableRedrawing
      Meteor.clearTimeout ModMan._timeoutID if ModMan._timeoutID
      ModMan._timeoutID = Meteor.setTimeout(->
        # Draw only if code changed
        transformedCode = ScoreMan.transformCode(ModMan.getCurrentCode(), ModMan.config.tabType)
        unless ModMan.vexMan.currentPage.code is transformedCode
          ModMan.vexMan.currentPage.code = transformedCode
          ModMan.vexMan.currentPage.redraw()
      , 200)

  @getCurrentCode = ->
    selection = ModMan.editor.getSelection()
    return selection  if selection isnt ""
    allLines = ModMan.editor.getValue().split("\n")
    cursorLine = ModMan.editor.getCursor().line
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
