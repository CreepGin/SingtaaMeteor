Meteor.startup ->
  #Forums.remove {}
  #Threads.remove {}
  Threads.update
    _id: "WWdf8kkQcELPxEGnf"
  ,
    $set:
      type: "sticky"
  if Forums.find().count() is 0
    forums = [
      name: "General"
      slug: "general"
      description: "Anything goes."
      weight: 1
    ,
      name: "Learning & Requests"
      slug: "learning"
      description: "Learn, teach, and request music here."
      weight: 2
    ,
      name: "Developer"
      slug: "developer"
      description: "Singtaa is developer-friendly. Come in for dev resources and questions."
      weight: 3
    ,
      name: "Help & Support"
      slug: "help"
      description: "Technical issues? Come on in and get help."
      weight: 4
    ,
      name: "Suggestions & Feedbacks"
      slug: "feedback"
      description: "Give us all your feedbacks. We love to improve."
      weight: 5
    ] 
    for forum in forums
      _.extend forum, 
        lastThreadId: undefined
        stickies: []
      Forums.insert forum
