

Template.forum.forum = ->
  Session.get "forum"

Template.forum.stickyThreads = ->
  forum = Session.get "forum"
  threads = Threads.find
    _id:
      $in: forum.stickies
  appendUsers threads.fetch()

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
  appendUsers threads.fetch()

Template._thread.events = 
  "click .user-link": (event) ->
    event.stopPropagation()
  "click .thread": (event) ->
    event.stopPropagation()
    ele = $(event.currentTarget)
    url = ele.find("h4 a").attr("href")
    Meteor.Router.to(url)