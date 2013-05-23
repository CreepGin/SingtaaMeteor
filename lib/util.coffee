@log = (text) ->
  if Meteor.settings and Meteor.settings.public and Meteor.settings.public.mode is "production"
    return
  if console and console.log
    console.log text

@t = (text) ->
  key = text.toLowerCase()
  lang = Session.get("lang")
  (if _.has(locale, lang) and _.has(locale[lang], key) then locale[lang][key] else text)

#find and add the user object to every object of a collection
@appendUsers = (collection) ->
  for c in collection
    c.user = Meteor.users.findOne
      _id: c.userId
  collection