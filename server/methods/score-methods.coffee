Meteor.methods
  saveScore: (data) ->
    #Validations
    throw new Meteor.Error(422, "You need to be logged in.") unless this.userId
    
    data = _.pick data, "title", "description", "tags", "score", "public", "id"
    data.score = _.pick data.score, "textPages", "tabType", "tempo", "beat"
    v = []
    v.push _.presenceOf "title", "Title should not be empty."
    v.push _.lengthOf "title",
      gte: 4
      lte: 140
      message: "Title should be between 4 to 140 chars."
    v.push _.lengthOf "description",
      gte: 1
      lte: 2000
      message: "Description needs to be under 2000 chars."
    v.push _.isArrayOf "tags",
      gte: 0
      lte: 16
      message: "There can be a maximum of 16 tags."
    v.push _.presenceOf "score.textPages", "Score should not be empty."
    v.push _.isArrayOf "score.textPages",
      gte: 1
      lte: 32
      message: "There can be a maximum of 32 pages."
    v.push _.isOneOfOf "score.tabType", ["tab", "single", "grand"]
    v.push _.isOneOfOf "score.tempo", [30, 60, 90, 120, 160, 200, 240, 300, 360, 420]
    v.push _.isOneOfOf "score.beat", [1, 2, 4, 8, 16, 32]
    v.push _.isOneOfOf "public", [true, false]

    errors = _.validate data, v
    messages = _.flatErrors errors
    throw new Meteor.Error(422, messages[0])  if messages.length > 0
    #End of Validations

    if data.id
      score = Scores.findOne
        _id: data.id
        userId: this.userId
      throw new Meteor.Error(422, "Error Updating Score") if not score
      data.updatedAt = new Date()
      Scores.update 
        _id: data.id
      ,
        $set: data
      return data.id

    data.updatedAt = data.createdAt = data.viewedAt = new Date()
    data.views = data.comments = data.upVotes = data.downVotes = 0
    data.userId = this.userId
    Scores.insert data

  viewedScore: (id) ->
    Scores.update
      _id: id
      public: true
      userId:
        $ne:
          this.userId
    ,
      $set:
        viewedAt: new Date()
      $inc:
        views: 1