Template.userside.rendered = ->
  ""

Template.userside.user = ->
  Session.get "usersideUser"

Template.userside.myScore = ->
  Session.get "myScore"

Template.userside.events = 
  "click .sign-in": (event) ->
    Accounts._loginButtonsSession.set('dropdownVisible', true);
    Meteor.setTimeout ->
      $("#login-username-or-email").focus()
    , 500

Meteor.autorun ->
  user = Meteor.user()
  myScore = Session.get "myScore"
  if myScore
    userId = myScore.userId
    Meteor.subscribe "user", userId
    user = Meteor.users.findOne
      _id: userId
  if user
    Session.set "usersideUser", 
      username: user.username
      email: user.emails[0].address
  else
    Session.set "usersideUser", null