class @VexMan

  PAGE_HTML: '<div class="vex-tabdiv hidden"></div>'

  currentPage: undefined
  currentTextPage: undefined
  index: 0  #starts at 1
  max: 0
  
  constructor: (@container) ->
    @pages = []   #tabdivs
    @textPages = []
    @container.find(".vex-tabdiv").each (i, ele) =>
      @pages.push new Vex.Flow.TabDiv($(ele))
      @textPages.push ""
      @textPages
      @index = 1
      @max++
    if @pages.length > 0
      @currentPage = @pages[0]
      @currentTextPage = @textPages[0]

  init: (textPages) ->
    if not textPages or textPages.length is 0
      return
    @max = textPages.length
    @textPages = textPages
    @index = 1
    @currentTextPage = textPages[0]
    @container.find(".vex-tabdiv").remove()
    @pages = []
    for textPage in textPages
      ele = $(@PAGE_HTML)
      @container.append ele
      @pages.push new Vex.Flow.TabDiv ele
    @currentPage = @pages[0]
    @container.find(".vex-tabdiv").first().removeClass "hidden"

  addPage: (editorText) ->
    ele = $(@PAGE_HTML)
    @container.append ele
    @pages.push new Vex.Flow.TabDiv ele
    @textPages.push ""
    @textPages[@index-1] = editorText
    @currentTextPage = editorText
    @max++
    @index++ if @index is 0

  deletePage: ->
    if @index is 1 and @max is 1
      return
    @index--
    @pages.splice @index, 1
    @textPages.splice @index, 1
    @container.find(".vex-tabdiv").eq(@index).remove()
    @index = 1 if @index is 0
    @max--
    @currentPage = @pages[@index-1]
    @currentTextPage = @textPages[@index-1]
    @container.find(".vex-tabdiv").eq(@index-1).removeClass "hidden"

  next: (editorText) ->
    if @index is @max
      return
    @currentPage = @pages[@index]
    @currentTextPage = @textPages[@index]
    @textPages[@index-1] = editorText
    @container.find(".vex-tabdiv").addClass "hidden"
    @container.find(".vex-tabdiv").eq(@index).removeClass "hidden"
    @index++

  prev: (editorText) ->
    if @index is 1
      return
    @currentPage = @pages[@index-2]
    @currentTextPage = @textPages[@index-2]
    @textPages[@index-1] = editorText
    @container.find(".vex-tabdiv").addClass "hidden"
    @container.find(".vex-tabdiv").eq(@index-2).removeClass "hidden"
    @index--

  saveCurrentText: (editorText) ->
    @textPages[@index-1] = editorText

    
