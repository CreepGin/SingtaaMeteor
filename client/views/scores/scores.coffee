Template.scores.rendered = ->
  log "rendered"

Template.scores.test = ->
  return Session.get "test"