

Template.thread.forum = ->
  PS.get "forum"

Template.thread.thread = ->
  PS.get "thread"

Template.thread.replies = ->
  thread = PS.get "thread"
  replies = []
  if thread
    replies = Replies.find 
      threadId: thread._id
    replies = replies.fetch()
  replies

Template.thread.isOwn = ->
  thread = PS.get "thread"
  thread and thread.userId is Meteor.userId()

Template.thread.msg = ->
  Session.get "msg"

Template.thread.events = 
  "click .reply-btn": (event) ->
    event.preventDefault()
    ele = $(event.target)
    ele.popover
      content: t "You need to be logged in first."
      trigger: "manual"
    ele.popover "show"
