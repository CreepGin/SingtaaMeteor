#This static class is used to add a layer of "scoping" to Session variables
#so that different pages don't pollute each other
class @PageStore

  constructor: (@page) ->

  get: (name) ->
    Session.get "#{@page} - #{name}"

  set: (name, value) ->
    Session.set "#{@page} - #{name}", value

  equals: (name, value) ->
    Session.equals "#{@page} - #{name}", value

  
