var MapleRouter = Backbone.Router.extend({

  initialize: function() {
    //Simplifying default page routing
    for (var key in this.routes) {
      var endpoint = this.routes[key];
      if (!this[endpoint]) {
        var router = this;
        (function(){  //<-- this function block is needed to enforce proper scoping
          var templateName = endpoint;
          router[templateName] = function(){};
          router.route(key, templateName, function () {
            router.default(templateName);
          });
        })();
      }
    }
    //Fixing trailing slashes
    var re = new RegExp("(\/)+$", "g");
    this.route(/(.*)\/+$/, "trailFix", function (id) {
      id = id.replace(re, '');
      this.navigate(id, true);
    });
  },

  //Define custom routes below
  routes: {
    "": "home",
    "tunes": "tunes",
    "artists": "artists",
    "charts": "charts",
    "forums": "forums",
    "roadmap": "roadmap",
    "create": "create",
    "createatune": "createatune",
    "*action": "home" //Everything not matched routes to Home right now; need to implememnt 404's later
  },
  default: function (pagename) {  //Used in initialize() for easy routing for page templates
    Session.set("currentpage", pagename);
    //The following are 2 general purpose msgs for use by any page
    Session.set("errorMsg", null );
    Session.set("successMsg", null );
    if (typeof global.pageInits[pagename] == "function")
      global.pageInits[pagename]();
  }

});

Meteor.Router = new MapleRouter();

jQuery( document ).on( "click", "a.page-link", function( event ) {
  Meteor.Router.navigate( this.pathname, { trigger: true });
  event.preventDefault();
});
Meteor.startup(function () {
  var test = Backbone.history.start({ pushState: true });
});

//Routing with HandleBars Partials
Handlebars.registerHelper("page_view", function() {
  var page = Session.get("currentpage");
  if (Template[page])
    return Template[page]({});
  return "";
});