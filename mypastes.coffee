Pastes = new Meteor.Collection("pastes")

if Meteor.isClient
  class Router extends Backbone.Router
    routes:
      ''         : 'homepage'
      ':username': 'pastes'
    homepage: ->
      Session.set "homepage", true
    pastes: (username) ->
      Session.set "homepage", false
      Session.set "username", username

  router = new Router

  Template.main.homepage = -> Session.get("homepage")
  Template.main.nothomepage = -> !Session.get("homepage")
  Template.mypastes.pastes = ->
    username = Session.get("username")
    result = Pastes.findOne(username: username)
    result.pastes.reverse() if result?
    return result
  Template.mypastes.events
    'keydown #input': (e) ->
      # 86 is 'v'
      if e.ctrlKey and (e.keyCode == 86)
        setTimeout (-> document.getElementById('submit').click()), 10
    'submit': ->
      paste = $("#input").val()
      return false if not paste.trim().length
      $("#input").val ''
      # upsert is not supported yet
      username = Session.get("username")
      pastes = Pastes.findOne(username: username)
      if pastes
        Pastes.update({username: username}, $push: {pastes: paste})
      else
        Pastes.insert
          username: username
          pastes: [paste]
      return false

  Meteor.startup ->
    Backbone.history.start(pushState: true)

if Meteor.isServer
  Meteor.startup ->
