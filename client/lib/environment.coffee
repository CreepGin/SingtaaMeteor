#Setups
Meteor.startup ->
  #Localization Setup
  langCookie = Cookie.get("lang")
  if langCookie and not Session.equals("lang", langCookie)
    Session.set("lang", langCookie)
  else
    Session.set("lang", "en")
