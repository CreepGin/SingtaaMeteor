class @PublishHelper

  @getUsersForCursor: (cursor) ->
    userIds = []
    cursor.forEach (c) ->
      userIds.push c.userId
    Meteor.users.find
      _id:
        $in: userIds