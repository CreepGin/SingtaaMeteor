Meteor.publish "forums", ->
  forums = Forums.find()
  threadIds = []
  forums.forEach (forum) ->
    threadIds.push forum.lastThreadId
  threads = Threads.find
    _id:
      $in: threadIds
  return [ forums, threads, PublishHelper.getUsersForCursor(threads) ]

Meteor.publish "stickyThreads", (forumSlug) ->
  forum = Forums.findOne
    slug: forumSlug
  threads = Threads.find
    _id:
      $in: forum.stickies
  ,
    fields: 
      'title': 1
      'createdAt': 1
      'userId': 1
      'replies': 1
      'type': 1
  return [ threads, PublishHelper.getUsersForCursor(threads) ]

Meteor.publish "threads", (forumSlug, skip, limit) ->
  threads = Threads.find
    forumSlug: forumSlug
  ,
    sort:
      createdAt: -1
    skip: skip
    limit: limit
  ,
    fields: 
      'title': 1
      'createdAt': 1
      'userId': 1
      'replies': 1
      'type': 1
  return [ threads, PublishHelper.getUsersForCursor(threads) ]

Meteor.publish "thread", (id) ->
  threads = Threads.find
    _id: id
  return [ threads, PublishHelper.getUsersForCursor(threads) ]

Meteor.publish "replies", (threadId, skip, limit) ->
  replies = Replies.find
    threadId: threadId
  ,
    sort:
      createdAt: 1
    skip: skip
    limit: limit
  return [ replies, PublishHelper.getUsersForCursor(replies) ]

