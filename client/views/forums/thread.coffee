
Template.thread.forum = ->
  threadId = Session.get "threadId"
  thread = Threads.findOne
    _id: threadId
  if thread
    Session.set "thread", thread
    return Forums.findOne
      slug: thread.forumSlug
  undefined


Template.thread.thread = ->
  Session.get "thread"