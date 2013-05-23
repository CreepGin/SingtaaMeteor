Meteor.subscribe "forums"

Template.forums.rendered = ->
  ""

Template.forums.forums = ->
  forums = Forums.find {},
    sort:
      weight: 1
  forums = forums.fetch()
  for forum in forums
    forum.thread = Threads.findOne
      _id: forum.lastThreadId
    if forum.thread
      forum.thread.user = Meteor.users.findOne
        _id: forum.thread.userId
  forums