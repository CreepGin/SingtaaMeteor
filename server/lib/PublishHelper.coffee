class @PublishHelper

  @getUsersForCursor: (collection) ->
    userIds = []
    collection.forEach (c) ->
      userIds.push c.userId
    Meteor.users.find
      _id:
        $in: userIds