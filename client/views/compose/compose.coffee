_loadEditorAndVex = (myScore) ->
  if myScore and ModMan.vexMan
    Session.set "myScore", myScore
    ModMan.vexMan.init(myScore.score.textPages)
    ModMan.tickMenu $("#tabType").parent().find("li a[rel='#{myScore.score.tabType}']")[0]
    ModMan.tickMenu $("#tempo").parent().find("li a[rel='#{myScore.score.tempo}']")[0]
    ModMan.tickMenu $("#beat").parent().find("li a[rel='#{myScore.score.beat}']")[0]
    ModMan.updateEditor()
    ModMan.redrawTab()

Template.compose.rendered = ->
  log "rendered"
  #if this.rendered
  #  return
  #$('input[type="checkbox"]').prettyCheckable()
  
  ModMan.setupUnity()
  ModMan.setupVexFlow()
  ModMan.setupEditor()

  _loadEditorAndVex Session.get "myScore"
  
  this.rendered = true

Template.compose.events = ModMan.menuEvents

Template.compose.msg = ->
  Session.get "msg"

Template.compose.isEditableScore = ->
  Session.get "isEditableScore"

Template.compose.myScore = ->
  Session.get "myScore"

Meteor.autorun ->
  Meteor.subscribe "score", Session.get("myScoreId")

Meteor.autorun ->
  myScore = Scores.findOne(
      _id: Session.get("myScoreId")
  )
  Session.set "myScore", myScore
  _loadEditorAndVex(myScore)

Meteor.autorun ->
  isEditableScore = no
  myScore = Session.get "myScore"
  if not Meteor.userId()
    isEditableScore = no
  else if not myScore
    isEditableScore = yes
  else if myScore.userId is Meteor.userId()
    isEditableScore = yes
  Session.set "isEditableScore", isEditableScore

