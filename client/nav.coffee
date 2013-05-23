Template.nav.navLinks = ->
  links = [
    name: "scores"
    href: "/scores"
  ,
    name: "forums"
    href: "/forums"
  ,
    name: "roadmap"
    href: "/roadmap"
  ,
    name: "dev"
    href: "/dev"
  ]
  for i of links
    link = links[i]
    link.templ = link.name  unless _.has(link, "templ")
    link.active = true  if Meteor.Router.page() is link.templ
  links


#Language Picker
if Meteor.isClient
  Meteor.startup ->
    jQuery(document).on "click", ".lang-picker a", (event) ->
      lang = $(this).attr("data-lang")
      if lang is "more"
        Meteor.Router.navigate "locale",
          trigger: true
        return
      Cookie.set "lang", lang
      Session.set "lang", lang



#User Account Dropdown menu overrides and setups
Template._loginButtonsLoggedInDropdownActions.rendered = ->
  
  #Move all this to a template if it gets too bloated here.
  $ = jQuery
  createAuctionButton = $("<div id=\"create-score\" class=\"login-button\">Compose</div>")
  $("#login-buttons-open-change-password").before createAuctionButton
  userProfileButton = $("<div class=\"login-button\" id=\"user-profile\">My Profile</div>")
  createAuctionButton.after userProfileButton

Template._loginButtonsLoggedInDropdownActions.events =
  "click #create-score": (event) ->
    Meteor.Router.to('/compose');
    Accounts._loginButtonsSession.closeDropdown()

  "click #user-profile": (event) ->
    Meteor.Router.to('/profile');
    Accounts._loginButtonsSession.closeDropdown()

  "click #login-buttons-logout": ->
    #Meteor.logout ->
    #  Meteor.Router.to('/');
    #  Accounts._loginButtonsSession.closeDropdown()
