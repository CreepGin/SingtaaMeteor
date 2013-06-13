###
TODO: Need to use a better pattern for separating individual page's routing logic
      This file will get crowded quickly as is
###

#Bootstraps every page's initialization. Also traps reactivity
_setPage = (name, args) ->
  PS.page = name
  Session.set "msg", undefined
  Session.set "modalMsg", undefined
  PS.set "pagingData", undefined
  Deps.autorun ->
    Template[name]["init"].apply(null, args) if typeof Template[name].init is "function" and typeof args is "object"
    args() if typeof args is "function"
  name

Meteor.Router.add
  "/compose": ->
    _setPage "compose", ->
      unless Meteor.userId()
        Meteor.Router.to("/")
        return
      PS.set "score", undefined
      Session.set "sideUserId", Meteor.userId()
  "/compose/:id": (id) ->
    _setPage "compose", ->
      unless Meteor.userId()
        Meteor.Router.to("/")
        return
      handle = Meteor.subscribe "score", id
      if handle.ready()
        score = Scores.findOne
          _id: id
        ,
          reactive: false
        PS.set "score", score
        Session.set "sideUserId", Meteor.userId()
  "/score/:id": (id) ->
    Meteor.call "viewedScore", id
    _setPage "score", ->
      Meteor.subscribe "score", id, ->
        score = Scores.findOne
          _id: id
        ,
          reactive: false
        PS.set "score", score
        PS.set "editable", false
        if score
          Session.set "sideUserId", score.userId
  "/profile": ->
    unless Meteor.userId()
      return "home"
    "profile"

  "/scores": ->
    _setPage "scores"
  #forums
  "/forums": ->
    _setPage "forums", ->
      Meteor.subscribe "forums"
  "/forum/:slug": (slug) ->
    _setPage "forum", [slug, 1]
  "/forum/:slug/:page": (slug, page) ->
    _setPage "forum", [slug, Number(page)]
  "/forum/:slug/post": (slug) ->
    _setPage "threadPost", ->
      PS.set "threadPreview", undefined
      PS.set "thread", undefined
      PS.set "forum", Forums.findOne
        slug: slug
  "/thread/edit/:id": (id) ->
    _setPage "threadPost", ->
      PS.set "threadPreview", undefined
      PS.set "thread", undefined
      handle = Meteor.subscribe "thread", id
      if handle.ready()
        thread = Threads.findOne
          _id: id
        PS.set "thread", thread
        if thread
          forum = Forums.findOne
            slug: thread.forumSlug
          PS.set "forum", forum
  "/thread/:id/:slug": (id) ->
    _setPage "thread", [id, 1]
  "/thread/:id/:slug/:page": (id, slug, page) ->
    _setPage "thread", [id, Number(page)]

  #End of forums
  "/roadmap": "roadmap"
  "/dev": "dev"
  "*": ->
    _setPage "home", ->
      Session.set "sideUserId", Meteor.userId()

Meteor.Router.beforeRouting = ->
  ""

