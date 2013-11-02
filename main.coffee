if Meteor.isServer
    #cursor returned is not limited by publish method. This returns ALL regions in collection.
    regions = Regions.find({})
    regions.observeChanges
        added: (id, fields) ->
            console.log "added: " + fields.name
        changed: (id, fields) ->
            console.log EJSON.stringify(fields)
    regions.forEach((region)->
        console.log "this region is: " + region.name
        rooms = Rooms.find({region: region.name})
        rooms.forEach((room)->
            console.log room.name
        )
    )

if Meteor.isClient
    Deps.autorun(()->
        Meteor.subscribe("characters", {
            onError: (err) -> 
                console.log(err.error + " " + err.reason)
            onReady: ->
                #currentRoom = Characters.findOne({owner: Meteor.userId()})
                #console.log currentRoom
        })

        player = Characters.findOne({owner: Meteor.userId()})
        if player?
            #console.log Meteor.userId() + " : " + player.currentRoom
            Meteor.subscribe("regions", player.currentRoom, {onError: (err) -> console.log(err.error + " " + err.reason)})
            region = Regions.findOne({})

            Meteor.subscribe("rooms", region, {onError: (err) -> console.log(err.error + " " + err.reason)})

            Meteor.subscribe("messages", player.currentRoom, Session.get("sessionStart"), {
                onError: (err) -> 
                    console.log(err.error + " " + err.reason)
            })
    )
    ### HELPER FUNCTION ###
    okcancel_events = (selector) ->
        return 'keyup ' +selector+', keydown '+selector+', focusout '+selector

    make_okcancel_handler = (options) ->
        ok = options.ok or ()->
        cancel = options.cancel or ()->

        return (evt) ->
            if evt.type is "keydown" and evt.which is 27
                cancel.call(this, evt)
            else if evt.type is "keyup" and evt.which is 13
                value = String(evt.target.value or "")

                if value
                    ok.call(this, value, evt)
                else
                    cancel.call(this, evt)

    ### BEGIN ROUTER LOGIC ###

    Router.map ->
        @route 'home', path: '/'
        @route 'world', path: '/world', controller: @WorldController
        @route 'character', path: '/character', controller: @CharacterController
        #@route 'sign_in', path: '/sign-in'
        @route 'create_account', path: '/create_account'
        @route 'notfound', path: '*'
    
    class @WorldController extends RouteController
        onBeforeRun: () ->
            if not Meteor.user()
                this.render('sign_in')
                this.stop()
        onBeforeRerun: () ->
            @onBeforeRun()
    class @CharacterController extends RouteController
        onBeforeRun: () -> 
            if not Meteor.user()
                this.render('sign_in')
                this.stop()
        onBeforeRerun: () ->
            @onBeforeRun()

    #Template.rooms.helpers(
    #    rooms: -> rooms
    #)
    ### BEGIN TEMPLATE LOGIC ###
    # Template.entry.events = {}

    #Template.entry.events[okcancel_events('#messageBox')] = make_okcancel_handler({
    #    ok: (text, event) ->
    #        nameEntry = $("#name").val()
    #        if nameEntry
    #            ts = Date.now() / 1000
    #            Messages.insert({name: nameEntry, message: text, time: ts})
    #            event.target.value = ""
    #})
if Meteor.isServer
    test = new share.Enemy("mogdor")
    tick = setInterval(()->
        test.tick()
        clearInterval(this)
    , 1000)