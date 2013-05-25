

Template.forum.forum = ->
  Session.get "forum"

Template.forum.stickyThreads = ->
  forum = Session.get "forum"
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
  appendUsers orderedThreads

Template.forum.threads = ->
  forum = Session.get "forum"
  threads = Threads.find
    forumSlug: forum.slug 
    type: 
      $ne:
        "sticky"
  ,
    sort:
      createdAt: -1
  collection = threads.fetch()
  return [] if collection.length is 0
  appendUsers collection

Template._thread.events = 
  "click .user-link": (event) ->
    event.stopPropagation()
  "click .thread": (event) ->
    event.stopPropagation()
    ele = $(event.currentTarget)
    url = ele.find("h4 a").attr("href")
    Meteor.Router.to(url)