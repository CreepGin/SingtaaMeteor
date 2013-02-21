Template.nav.navLinks = function() {
  var links = [
    { name: "tunes", href: "/tunes" },
    { name: "artists", href: "/artists" },
    { name: "charts", href: "/charts" },
    { name: "forums", href: "/forums" },
    { name: "roadmap", href: "/roadmap" }
  ];
  for (var i in links){
    var link = links[i];
    if (!_.has(link, "templ"))
      link.templ = link.name;
    if (Session.equals("currentpage", link.templ))
      link.active = true;
  }
  return links;
}

//Language Picker
if (Meteor.isClient) {
  Meteor.startup(function () {
    jQuery( document ).on( "click", ".lang-picker a", function( event ) {
      var lang = $(this).attr("data-lang");
      if (lang == "more"){
        Meteor.Router.navigate("locale", {trigger: true});
        return;
      }
      Cookie.set("lang", lang);
      Session.set("lang", lang);
    });
  });
}

//User Account Dropdown menu overrides and setups
Template._loginButtonsLoggedInDropdownActions.rendered = function(){
  //Move all this to a template if it gets too bloated here.
  var $ = jQuery;
  var createAuctionButton = $('<div id="create-tune" class="login-button">Create a Tune</div>');
  $("#login-buttons-open-change-password").before(createAuctionButton);
  var userProfileButton = $('<div class="login-button" id="user-profile">My Profile</div>');
  createAuctionButton.before(userProfileButton);
}
Template._loginButtonsLoggedInDropdownActions.events = {
  'click #create-tune': function (event) {
    Meteor.Router.navigate("createatune", {trigger: true});
    Accounts._loginButtonsSession.closeDropdown();
  },
  'click #user-profile': function (event) {
    Meteor.Router.navigate("profile", {trigger: true});
    Accounts._loginButtonsSession.closeDropdown();
  },
  'click #login-buttons-logout': function() {
    Meteor.logout(function () {
      Meteor.Router.navigate("", {trigger: true});
      Accounts._loginButtonsSession.closeDropdown();
    });
  }
}