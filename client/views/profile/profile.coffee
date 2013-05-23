do ->

  Meteor.autorun ->
    Meteor.subscribe "my-user"

  Template.profile.user = ->
    Meteor.user()

  Template.profile.gravatarUrl = ->
    user = Meteor.user()
    Gravatar.imageUrl(user.emails[0].address) if user and user.emails[0]

  Template.profile.createdAt = ->
    user = Meteor.user()
    if user
      moment(user.createdAt).calendar()