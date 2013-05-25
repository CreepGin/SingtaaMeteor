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

Meteor.publish "allScores", ->
  Scores.find({})

Meteor.publish "allUserData",  ->
  Meteor.users.find {}

