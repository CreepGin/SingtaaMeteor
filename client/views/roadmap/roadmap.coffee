Template.roadmap.techItems = ->
  items = []
  for i in [0..12]
    items.push $.fn.lorem 
      type: 'words'
      amount: Math.floor(Math.random() * 30) + 20
      ptags:false
  items

Template.roadmap.nontechItems = ->
  items = []
  for i in [0..8]
    items.push $.fn.lorem
      type: 'words'
      amount: Math.floor(Math.random() * 30) + 20
      ptags:false
  items
