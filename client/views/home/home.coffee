Meteor.subscribe "allScores"
Meteor.subscribe "allUserData"

Template.home.mostViewed = ->
  Scores.find {},
    sort:
      views: -1
    fields:
      title: 1
      views: 1
      userId: 1
      upVotes: 1
      downVotes: 1
    limit: 10

Template.home.latest = ->
  Scores.find {},
    sort:
      createdAt: -1
    fields:
      title: 1
      views: 1
      userId: 1
      upVotes: 1
      downVotes: 1
    limit: 8

Template.home.beingViewed = ->
  Scores.find {},
    sort:
      viewedAt: -1
    fields:
      title: 1
      views: 1
      userId: 1
      upVotes: 1
      downVotes: 1
    limit: 8

Template.homeScoreItem.user = ->
  Meteor.users.findOne
    _id: this.userId
  ,
    fields:
      username: 1