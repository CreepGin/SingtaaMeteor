Template.userside.rendered = ->
  ""

Template.userside.user = ->
  user = Meteor.users.findOne
    _id: Session.get "sideUserId"
  if user
    user.email = user.emails[0].address
  user

Template.userside.events = 
  "click .sign-in": (event) ->
    Accounts._loginButtonsSession.set('dropdownVisible', true);
    Meteor.setTimeout ->
      $("#login-username-or-email").focus()
    , 500
