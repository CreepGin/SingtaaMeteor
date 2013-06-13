Meteor.methods
  saveThread: (data) ->
    #Validations
    throw new Meteor.Error(422, "You need to be logged in.") unless this.userId

    data = _.pick data, "title", "body", "forumSlug", "id"
    v = []
    v.push _.presenceOf "title", "Title should not be empty."
    v.push _.lengthOf "title",
      gte: 4
      lte: 140
      message: "Title should be between 4 to 140 chars."
    v.push _.presenceOf "body", "Body should not be empty."
    v.push _.lengthOf "body",
      gte: 20
      lte: 8000
      message: "Body should be between 20 to 8000 chars."
    v.push _.isOneOfOf "forumSlug", ["general", "learning", "developer", "help", "feedback"]

    errors = _.validate data, v
    messages = _.flatErrors errors
    throw new Meteor.Error(422, messages[0]) if messages.length > 0

    forum = Forums.findOne
      slug: data.forumSlug
    throw new Meteor.Error(422, "Forum not found.") if not forum
    #End of Validations

    if data.id
      #find thread
      thread = Threads.findOne
        _id: data.id
        userId: this.userId
      throw new Meteor.Error(404, "Thread not found or user not authenticated.") if not thread
      throw new Meteor.Error(404, "Thread was already deleted.") if thread.type is "deleted"
      #update thread
      data.updatedAt = new Date()
      Threads.update 
        _id: data.id
      ,
        $set: _.omit data, "id"
      id = data.id
    else
      #insert new thread
      data.updatedAt = data.createdAt = data.viewedAt = data.repliedAt = new Date()
      data.views = data.replies = data.upVotes = data.downVotes = 0
      data.userId = this.userId
      data.type = "regular" #other types: "deleted", "sticky"
      id = Threads.insert data
      #update user
      Meteor.users.update 
        _id: this.userId
      ,
        $inc:
          "meta.posts": 1
        $set:
          "meta.lastPostAt": new Date()
      #update forum
      Forums.update
        _id: forum._id
      ,
        $set:
          lastThreadId: id

    id

  deleteThread: (threadId) ->
    thread = Threads.findOne
      _id: threadId
      userId: this.userId
    throw new Meteor.Error(404, "Thread not found or user not authenticated.") if not thread
    Threads.update 
      _id: threadId
    ,
      $set: 
        type: "deleted"
        body: ""
    "success"

  saveReply: (data) ->
    #Validations
    throw new Meteor.Error(422, "You need to be logged in.") unless this.userId

    data = _.pick data, "threadId", "body", "id"
    v = []
    v.push _.presenceOf "body", "Body should not be empty."
    v.push _.lengthOf "body",
      gte: 4
      lte: 8000
      message: "Body should be between 20 to 8000 chars."

    errors = _.validate data, v
    messages = _.flatErrors errors
    throw new Meteor.Error(422, messages[0]) if messages.length > 0

    thread = Threads.findOne
      _id: data.threadId
    throw new Meteor.Error(422, "Thread not found.") if not thread
    throw new Meteor.Error(404, "Thread was already deleted.") if thread.type is "deleted"
    #End of Validations

    if data.id
      #find reply
      reply = Replies.findOne
        _id: data.id
        userId: this.userId
      throw new Meteor.Error(404, "Reply not found or user not authenticated.") if not reply
      #update reply
      data.updatedAt = new Date()
      Replies.update 
        _id: data.id
      ,
        $set: _.omit data, "id"
      id = data.id
    else
      #insert new reply
      data.updatedAt = data.createdAt = new Date()
      data.upVotes = data.downVotes = 0
      data.userId = this.userId
      data.type = "regular" #other types: "deleted"
      id = Replies.insert data
      Threads.update
        _id: thread._id
      ,
        $inc:
          replies: 1
        $set:
          repliedAt: new Date()
      #update user
      Meteor.users.update 
        _id: this.userId
      ,
        $inc:
          "meta.posts": 1
        $set:
          "meta.lastPostAt": new Date()
      #update forum
      Forums.update
        slug: thread.forumSlug
      ,
        $set:
          lastThreadId: thread._id

    id

  deleteReply: (replyId) ->
    reply = Replies.findOne
      _id: replyId
      userId: this.userId
    throw new Meteor.Error(404, "Reply not found or user not authenticated.") if not reply
    Replies.update 
      _id: replyId
    ,
      $set: 
        type: "deleted"
        body: ""
    "success"

  getNumThreads: (forumSlug) ->
    threads = Threads.find
      forumSlug: forumSlug
    threads.count()

  getNumReplies: (threadId) ->
    replies = Replies.find
      threadId: threadId
    replies.count()
