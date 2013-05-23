#Helpers
_getUsersForCursor = (collection) ->
  userIds = []
  collection.forEach (c) ->
    userIds.push c.userId
  Meteor.users.find
    _id:
      $in: userIds
#End of helpers

Meteor.publish "my-score", (id) ->
  Scores.find 
    _id: id
    userId: @userId

Meteor.publish "score", (id) ->
  publics = Scores.find 
    _id: id
    $or: [
      public: true
    ,
      userId: @userId
    ]

Meteor.publish "user", (id) ->
  Meteor.users.find 
    _id: id
  , 
    fields: 
      'createdAt': 1
      'emails': 1
      'username': 1

Meteor.publish "my-user", ->
  Meteor.users.find 
    _id: this.userId
  , 
    fields: 
      'createdAt': 1
      'emails': 1
      'username': 1

#Forums 
Meteor.publish "forums", ->
  forums = Forums.find()
  threadIds = []
  forums.forEach (forum) ->
    threadIds.push forum.lastThreadId
  threads = Threads.find
    _id:
      $in: threadIds
  return [ forums, threads, _getUsersForCursor(threads) ]

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
  return [ threads, _getUsersForCursor(threads) ]

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
  return [ threads, _getUsersForCursor(threads) ]

Meteor.publish "thread", (id) ->
  threads = Threads.find
    _id: id
  ,
    sort:
      createdAt: -1
    skip: skip
    limit: limit
  return [ threads, _getUsersForCursor(threads) ]

#End of Forums 

Meteor.publish "allScores", ->
  Scores.find({})

Meteor.publish "allUserData",  ->
  Meteor.users.find {}

