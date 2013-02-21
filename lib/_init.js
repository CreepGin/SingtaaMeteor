global = {
    pageInits: {}
};

if (Meteor.isClient) {
  Meteor.startup(function () {

    //Localization Setup
    var langCookie = Cookie.get("lang");
    if (langCookie && !Session.equals("lang", langCookie)){
      Session.set("lang", langCookie);
    }else{
      Session.set("lang", "en");
    }
    
  });
}