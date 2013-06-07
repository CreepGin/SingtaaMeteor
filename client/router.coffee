#Bootstraps every page's initialization. Also traps reactivity
_setPage = (name, func) ->
  PS.page = name
  Session.set "msg", undefined
  Deps.autorun ->
    Template[name].init() if typeof Template[name].init is "function"
    func() if typeof func is "function"
  name

Meteor.Router.add
  "/compose": ->
    _setPage "compose", ->
      unless Meteor.userId()
        return "home"
      PS.set "score", undefined
      Session.set "sideUserId", Meteor.userId()
  "/compose/:id": (id) ->
    _setPage "compose", ->
      unless Meteor.userId()
        return "home"
      Meteor.subscribe "score", id
      score = Scores.findOne
        _id: id
      PS.set "score", score
      Session.set "sideUserId", Meteor.userId()
  "/score/:id": (id) ->
    Meteor.call "viewedScore", id
    _setPage "score", ->
      Meteor.subscribe "score", id
      score = Scores.findOne
        _id: id
      PS.set "score", score
      PS.set "editable", false
      if score
        Session.set "sideUserId", score.userId
  "/profile": ->
    unless Meteor.userId()
      return "home"
    "profile"

  "/scores": ->
    "scores"
  #forums
  "/forums": ->
    Meteor.subscribe "forums"
    "forums"
  "/forum/:slug": (slug) ->
    forum = Forums.findOne
      slug: slug
    Session.set "forum", forum
    return "forums" unless forum
    Meteor.subscribe "stickyThreads", forum.slug
    Meteor.subscribe "threads", forum.slug, 0, GLOBAL.FORUM_THREADS_PER_PAGE
    "forum"
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
      Meteor.subscribe "thread", id
      thread = Threads.findOne
        _id: id
      PS.set "thread", thread
      if thread
        forum = Forums.findOne
          slug: thread.forumSlug
        PS.set "forum", forum
  "/thread/:id/:slug": (id) ->
    _setPage "thread", ->
      Meteor.subscribe "thread", id
      thread = Threads.findOne
        _id: id
      PS.set "thread", thread
      if thread
        forum = Forums.findOne
          slug: thread.forumSlug
        PS.set "forum", forum

  #End of forums
  "/roadmap": "roadmap"
  "/dev": "dev"
  "*": ->
    _setPage "home"

Meteor.Router.beforeRouting = ->
  ""

