Template.threadPost.rendered = ->
  if not $("#body").hasClass "autogrow"
    $("#body").autogrow()
    $("#body").addClass "autogrow"

Template.threadPost.events = 
  "keyup #body": (event) ->
    ele = event.target
    Session.set "threadPreview", "\n" + $(ele).val()
  "click .save": (event) ->
    data = 
      title: $("#title").val()
      body: $("#body").val()
      forumSlug: Session.get("forum").slug
    log data
    Meteor.call "saveThread", data, (error, id) ->
      if error
        Session.set "msg", 
          type: "error"
          text: error.reason
      else
        Meteor.Router.to('/thread/'+id);
        Session.set "msg", 
          type: "success"
          text: "Your thread was created!"
    
Template.threadPost.forum = ->
  Session.get "forum"

Template.threadPost.msg = ->
  Session.get "msg"