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
      #update thread
      data.updatedAt = new Date()
      Threads.update 
        _id: data.id
      ,
        $set: data
      id = data.id
    else
      #insert new thread
      data.updatedAt = data.createdAt = data.viewedAt = new Date()
      data.views = data.replies = data.upVotes = data.downVotes = 0
      data.userId = this.userId
      data.type = "regular" #other types: "deleted", "sticky"
      id = Threads.insert data

    #update forum
    Forums.update
      _id: forum._id
    ,
      $set:
        lastThreadId: id

    id