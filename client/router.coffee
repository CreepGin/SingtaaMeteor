Meteor.Router.add
  "/compose": ->
    unless Meteor.userId()
      return "home"
    "compose"
  "/compose/:id": (id) ->
    Session.set "myScoreId", id
    Meteor.call "viewedScore", id
    "compose"
  "/score/:id": (id) ->
    Session.set "myScoreId", id
    Meteor.call "viewedScore", id
    "compose"
  "/profile": ->
    unless Meteor.userId()
      return "home"
    "profile"

  "/scores": ->
    "scores"
  "/forums": ->
    Meteor.subscribe "forums"
    "forums"
  "/forum/:slug": (slug) ->
    forum = Forums.findOne
      slug: slug
    Session.set "forum", forum
    log forum
    return "forums" unless forum
    Meteor.subscribe "stickyThreads", forum.slug
    Meteor.subscribe "threads", forum.slug, 0, GLOBAL.FORUM_THREADS_PER_PAGE
    "forum"
  "/forum/:slug/post": (slug) ->
    Session.set "threadPreview", undefined
    Session.set "forum", Forums.findOne
      slug: slug
    unless Session.get "forum"
      return "forums"
    "threadPost"
  "/thread/:id/:slug": (id) ->
    Meteor.subscribe "thread", id
    Session.set "threadId", id
    "thread"

  "/roadmap": "roadmap"
  "/dev": "dev"
  "*": "home"

Meteor.Router.beforeRouting = ->
  Session.set "myScoreId", undefined
  Session.set "myScore", undefined
  Session.set "msg", undefined