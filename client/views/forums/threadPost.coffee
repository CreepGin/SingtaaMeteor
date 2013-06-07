_refreshMarked = (ele) ->
    PS.set "threadPreview", "\n" + ele.val()

Template.threadPost.rendered = ->
  if not $("#body").hasClass "autogrow"
    $("#body").autogrow()
    $("#body").addClass "autogrow"
  _refreshMarked $("#body")

Template.threadPost.events = 
  "keyup #body": (event) ->
    _refreshMarked($(event.target))
  "click .save": (event) ->
    event.preventDefault()
    data = 
      title: $("#title").val()
      body: $("#body").val()
      forumSlug: PS.get("forum").slug
    thread = PS.get "thread"
    if thread
      data.id = thread._id
    Meteor.call "saveThread", data, (error, id) ->
      if error
        Session.set "msg", undefined
        Session.set "msg", 
          type: "error"
          text: error.reason
      else
        Meteor.Router.to("/thread/#{id}/#{slugifyText(data.title)}");
        Session.set "msg", 
          type: "success"
          text: "Your thread was saved!"
  "click .delete": (event) ->
    event.preventDefault()
    bootbox.confirm "Are you sure?", (res) ->
      if res is true
        Meteor.call "deleteThread", PS.get("thread")._id, (error, res) ->
          if error
            Session.set "msg", undefined
            Session.set "msg",
            type: "error"
            test: error.reason
          else
            Meteor.Router.to("/forum/" + PS.get("forum").slug);
            Session.set "msg", 
              type: "success"
              text: "Your thread was deleted!"
    
Template.threadPost.forum = ->
  PS.get "forum"

Template.threadPost.thread = ->
  PS.get "thread"

Template.threadPost.editable = ->
  PS.get "thread" and yes

Template.threadPost.msg = ->
  Session.get "msg"