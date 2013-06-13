Template.forum.init = (slug, page) ->
  forum = Forums.findOne
    slug: slug
  Session.set "forum", forum
  if forum
    Meteor.subscribe "stickyThreads", forum.slug
    Deps.autorun ->
      tpp = GLOBAL.FORUM_THREADS_PER_PAGE
      skip = if PS.get("pagingData") then (PS.get("pagingData").index - 1) * tpp else 0
      Meteor.subscribe "threads", forum.slug, skip + tpp, ->
        threads = Threads.find
          forumSlug: forum.slug 
          type: 
            $ne:
              "sticky"
        ,
          sort:
            repliedAt: -1
          skip: skip
          limit: tpp
        threads = threads.fetch()
        PS.set "threads", appendUsers(threads)
        unless PS.get("pagingData")
          Meteor.call "getNumThreads", slug, (err, numThreads) ->
            total = Math.ceil(numThreads / tpp) 
            PS.set "pagingData",
              index: if 1<= page <= total then page else 1
              total: total

Template.forum.rendered = ->
  $('.has-title').tooltip
    placement: "right"
  $('.has-title').tooltip "hide"

Template.forum.msg = ->
  Session.get "msg"

Template.forum.forum = ->
  Session.get "forum"

Template.forum.pagingData = ->
  PS.get "pagingData"

Template.forum.stickyThreads = ->
  forum = Session.get "forum"
  if forum
    threads = Threads.find
      _id:
        $in: forum.stickies
    collection = threads.fetch()
    return [] if collection.length is 0
    orderedThreads = []
    for stickyId in forum.stickies
      picked = _.find collection, (c) ->
        c._id is stickyId
      orderedThreads.push picked if picked
    return appendUsers orderedThreads
  []

Template.forum.threads = ->
  PS.get "threads"
  
Template._thread.events = 
  "click .user-link": (event) ->
    event.stopPropagation()
  "click .thread": (event) ->
    event.stopPropagation()
    ele = $(event.currentTarget)
    url = ele.find("h4 a").attr("href")
    Meteor.Router.to(url)