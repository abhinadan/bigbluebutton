define [
  'jquery',
  'underscore',
  'backbone',
  'globals',
  'cs!models/authentication',
  'cs!collections/meetings',
  'text!templates/login.html',
  'text!templates/login_loading.html',
], ($, _, Backbone, globals, AuthenticationModel, MeetingsCollection, loginTemplate, loginLoadingTemplate) ->

  LoginView = Backbone.View.extend
    id: 'login-view'
    model: new AuthenticationModel()

    events:
      "submit #login-form": "onLoginFormSubmit"

    render: ->
      # At first we render a simple "loading" page while we check if the
      # user is authenticated or not
      compiledTemplate = _.template(loginLoadingTemplate, {})
      @$el.html compiledTemplate

      # Go check the authentication
      @checkAuthentication()

      @

    # Method to render the template with the inputs that the user can
    # use to log in.
    renderLoginFields: ->
      # if the data was rendered in the page, use it, otherwise fetch it
      if globals.bootstrappedMeetings
        collection = new MeetingsCollection(globals.bootstrappedMeetings)
      else
        # TODO: test it
        collection = new MeetingsCollection()
        collection.fetch()

      data = { meetings: collection.models }
      compiledTemplate = _.template(loginTemplate, data)
      @$el.html compiledTemplate

    # Fetch information from the server to check if the user is autheticated
    # already or not.
    checkAuthentication: ->
      @model.fetch
        success: (model, response, options) =>
          if @model.get("loginAccepted")
            @onLoginAccepted()
          else
            @renderLoginFields()
        error: (model, xhr, options) =>
          console.log "Unexpected error fetching authentication data:", model, xhr, options
          @renderLoginFields()

    # Triggered when the login form is submitted.
    onLoginFormSubmit: ->
      params =
        "username": @$("#user-name").val()
        "meetingID": @$("#meeting-id").val()
      @model.save params,
        success: (model, response, options) =>
          if @model.get("loginAccepted")
            @onLoginAccepted()
          else
            # TODO: show the error in the screen
            globals.router.showLogin()
        error: (model, xhr, options) =>
          console.log "Unexpected error fetching authentication data:", model, xhr, options
          # TODO: show the error in the screen
          globals.router.showLogin()
      false

    # Actions to take when the login was authorized.
    onLoginAccepted: ->
      globals.currentAuth = @model
      globals.router.showSession()

  LoginView
