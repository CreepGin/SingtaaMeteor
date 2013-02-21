/*
* Generic Heplers go here
*/

//Convenient helper for selecting default option
Handlebars.registerHelper('selected', function(val, option) {
  return val == option ? ' selected' : '';
});
//Useful for checking session variables in templates
Handlebars.registerHelper('if_session', function(name, options) {
  if (Session.get(name))
    return options.fn(Session.get(name));
  return "";
});
Handlebars.registerHelper('get_session', function(name) {
  return Session.get(name);
});
Handlebars.registerHelper('t', function(name) {
  var lang = Session.get("lang");
  return _.has(locale, lang) && _.has(locale[lang], name) ? locale[lang][name] : name;
});