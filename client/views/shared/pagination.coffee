_pageCleanUp = ->
  Session.set "msg", undefined
  Session.set "modalMsg", undefined

Template.pagination.rendered = ->
  ""

Template.pagination.pageLinks = ->
  index = this.index
  total = this.total
  links = []
  for i in [1..total]
    link = 
      index: i
      type: if i is index then "active" else "regular"
    if i is 1 or i is total or index - 2 <= i <= index + 2
      links.push link
  links

Template.pagination.events = 
  "click .paging-link": (event) ->
    event.preventDefault()
    ele = $(event.target)
    index = parseInt ele.text()
    PS.set "pagingData", 
      index: index
      total: PS.get("pagingData").total
    _pageCleanUp()
  "click .prev": (event) ->
    event.preventDefault()
    pagingData = PS.get "pagingData"
    PS.set "pagingData",
      index: Math.max pagingData.index - 1, 1
      total: pagingData.total
    _pageCleanUp()
  "click .next": (event) ->
    event.preventDefault()
    pagingData = PS.get "pagingData"
    PS.set "pagingData",
      index: Math.min pagingData.index + 1, pagingData.total
      total: pagingData.total
    _pageCleanUp()