_loadEditorAndVex = (score) ->
  if score and ModMan.vexMan
    PS.set "score", score
    ModMan.vexMan.init(score.score.textPages)
    ModMan.tickMenu $("#tabType").parent().find("li a[rel='#{score.score.tabType}']")[0]
    ModMan.tickMenu $("#tempo").parent().find("li a[rel='#{score.score.tempo}']")[0]
    ModMan.tickMenu $("#beat").parent().find("li a[rel='#{score.score.beat}']")[0]
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

  _loadEditorAndVex PS.get "score"
  
  this.rendered = true

Template.compose.events = ModMan.menuEvents

Template.compose.msg = ->
  Session.get "msg"

Template.compose.isEditableScore = ->
  if PS.equals "editable", false
    return no
  isEditableScore = no
  score = PS.get "score"
  if not Meteor.userId()
    isEditableScore = no
  else if not score
    isEditableScore = yes
  else if score.userId is Meteor.userId()
    isEditableScore = yes
  isEditableScore

Template.compose.isMyScore = ->
  userId = Meteor.userId()
  score = PS.get "score"
  if userId and score and score.userId is userId
    return yes
  no

Template.compose.score = ->
  PS.get "score"

Meteor.autorun ->
  score = PS.get("scoreId")
  _loadEditorAndVex(score)
