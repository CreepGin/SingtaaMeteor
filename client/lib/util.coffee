class @Util

  @appendUsers: (collection) ->
    for c in collection
      c.user = Meteor.users.findOne
        _id: c.userId
    collection