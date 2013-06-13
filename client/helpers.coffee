#Convenient helper for selecting default option
Handlebars.registerHelper "selected", (val, option) ->
  (if val is option then " selected" else "")

#Useful for checking session variables in templates
Handlebars.registerHelper "if_session", (name, options) ->
  val = Session.get(name)
  return options.fn(val) if val
  options.inverse(val);

Handlebars.registerHelper "get_session", (name, field) ->
  obj = Session.get name
  if field and typeof obj is not "string"
    obj = _.nestedValue(obj, field)
  obj

Handlebars.registerHelper "if_ps", (name, options) ->
  val = PS.get(name)
  return options.fn(val) if val
  options.inverse(val);

Handlebars.registerHelper "get_ps", (name, field) ->
  obj = PS.get name
  if field and typeof obj is not "string"
    obj = _.nestedValue(obj, field)
  obj

Handlebars.registerHelper "tags2str", (tags) ->
  if tags
    tags.join(", ")

#translate
Handlebars.registerHelper "t", (name) ->
  t name

#Partial Picker
Handlebars.registerHelper "renderModule", (name, options) ->
  name = "module" + _.capitalize(name)
  if Template[name] then Template[name](this) else ""

#DB
Handlebars.registerHelper "getUsernameFromId", (userId) ->
  user = Meteor.users.findOne
    _id: userId
  ,
    fields:
      username: 1
  if user
    return user.username
  else
    return ""

#utils
Handlebars.registerHelper "gravatarUrl", (email) ->
  Gravatar.imageUrl(email) 

Handlebars.registerHelper "getDateStr", (date) ->
  moment(date).format('LL')

Handlebars.registerHelper "timeAgo", (date) ->
  moment(date).fromNow()

Handlebars.registerHelper "formatNumber", (number) ->
  accounting.formatNumber number

Handlebars.registerHelper "slugifyText", (text) ->
  slugifyText text

Handlebars.registerHelper "marked", (options) ->
  marked(options.fn(this))

Handlebars.registerHelper "null2zero", (text) ->
  unless text
    return 0
  return text
