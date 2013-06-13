_refreshMarked = (ele) ->
    PS.set "replyPreview", "\n" + ele.val()

Template.thread.init = (id, page) ->
  Deps.autorun ->
    Meteor.subscribe "thread", id,  ->
      Deps.autorun ->     #this is needed because the subscribe onReady callback is not autorun
        thread = Threads.findOne
          _id: id
        PS.set "thread", thread
        if thread
          forum = Forums.findOne
            slug: thread.forumSlug
          PS.set "forum", forum
          user = Meteor.users.findOne 
            _id: thread.userId
          PS.set "user", user
  Deps.autorun ->
    rpp = GLOBAL.FORUM_REPLIES_PER_PAGE
    skip = if PS.get("pagingData") then (PS.get("pagingData").index - 1) * rpp else 0
    Meteor.subscribe "replies", id, skip + rpp, ->
      replies = Replies.find 
        threadId: id
      ,
        sort:
          createdAt: 1
        skip: skip
        limit: rpp
      replies = replies.fetch()
      PS.set "replies", appendUsers(replies)
      unless PS.get("pagingData")
        Meteor.call "getNumReplies", id, (err, numReplies) ->
          total = Math.ceil(numReplies / rpp) 
          PS.set "pagingData",
            index: if 1<= page <= total then page else 1
            total: total

Template.thread.rendered = ->
  _refreshMarked $("#replyBody")

Template.thread.forum = ->
  PS.get "forum"

Template.thread.thread = ->
  PS.get "thread"

Template.thread.op = ->
  user = PS.get "user"
  user.email = user.emails[0].address
  user

Template.thread.replies = ->
  PS.get "replies"

Template.thread.pagingData = ->
  PS.get "pagingData"

Template.thread.isFirstPage = ->
  pagingData = PS.get "pagingData"
  pagingData and pagingData.index is 1

Template.thread.isOwn = ->
  thread = PS.get "thread"
  thread and thread.userId is Meteor.userId()

Template.thread.msg = ->
  Session.get "msg"

Template.thread.modalMsg = ->
  Session.get "modalMsg"

Template.thread.events = 
  "click .reply-btn": (event) ->
    event.preventDefault()
    ele = $(event.target)
    if not Meteor.userId()
      ele.popover
        content: t "You need to be logged in first."
        trigger: "manual"
      ele.popover "show"
    else
      PS.set "reply", undefined
      PS.set "replyPreview", ""
      $("#replyBody").val("")
      $("#replyModal").modal("show")
      $("#replyModal").off("shown").on "shown", ->
        $("#replyBody").focus()
  "click .edit": (event) ->
    ele = $(event.currentTarget)
    replyId = ele.attr "data-reply-id"
    reply = Replies.findOne 
      _id: replyId
    PS.set "reply", reply
    $("#replyBody").val reply.body
    _refreshMarked $("#replyBody")
    $("#replyModal").modal("show")
    $("#replyModal").off("shown").on "shown", ->
      $("#replyBody").focus()
  "click .delete": (event) ->
    ele = $(event.currentTarget)
    replyId = ele.attr "data-reply-id"
    bootbox.confirm t("Are you sure?"), (res) ->
      if res is true
        Meteor.call "deleteReply", replyId, (error, res) ->
          if error
            bootbox.alert t(error.reason)
          else
            bootbox.alert t("Your reply was deleted!")
  "click .save-reply": (event) ->
    event.preventDefault()
    data = 
      body: $("#replyBody").val()
      threadId: PS.get("thread")._id
    reply = PS.get "reply"
    if reply
      data.id = reply._id
    Meteor.call "saveReply", data, (error, id) ->
      if error
        Session.set "modalMsg", undefined
        Session.set "modalMsg", 
          type: "error"
          text: error.reason
      else
        $("#replyModal").modal("hide")
        Session.set "msg", 
          type: "success"
          text: "Your reply was saved!"
        Meteor.call "getNumReplies", PS.get("thread")._id, (err, numReplies) ->
          total = Math.ceil(numReplies / GLOBAL.FORUM_REPLIES_PER_PAGE) 
          PS.set "pagingData", undefined
          Deps.flush()
          PS.set "pagingData",
            index: total
            total: total
    ""
  "keyup #replyBody": (event) ->
    _refreshMarked($(event.target))