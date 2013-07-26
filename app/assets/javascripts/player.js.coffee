jQuery ->
  window.gameController = new Game.Controller($('#game').data('uri'), true);

window.Game = {}

class Game.Controller
  template: (message) ->
    html =
      """
            <div class="message" >
              <label class="label label-info">
                [#{message.received}]
              </label>&nbsp;
              #{message.msg_body}
            </div>
            """
    $(html)

  constructor: (url,useWebSockets) ->
    @messageQueue = []
    @dispatcher = new WebSocketRails(url,useWebSockets)
    $('#state').text(0)    # initial game state; 0 clicks
    @bindEvents()

  bindEvents: ->
    @dispatcher.bind 'new_message', @newMessage
    @dispatcher.bind 'please_subscribe', @subscribePrivate
    $('#send').on 'click', @clicked

  newMessage: (message) =>
    @messageQueue.push message
    @appendMessage message
    console.log(message)

  clicked: (event) =>
    event.preventDefault()
    @dispatcher.trigger 'clicked'
    $('#state').text(parseInt($('#state').text(), 10) + 1)

  updateClicks: (message) =>
    console.log(message)
    $('#state').text(message)

  appendMessage: (message) ->
    messageTemplate = @template(message)
    $('#game').append messageTemplate

  subscribePrivate: (message) =>
    console.log "subscribing private... #{message}"
    @privateChannel = @dispatcher.subscribe_private(message)
    @privateChannel.on_success = =>
      console.log "Subscribed to game_updates"
      @privateChannel.bind 'game_update', @updateClicks
    @privateChannel.on_failure = (reason) ->
      console.log "Couldn't subscribe to game updates because of #{reason.message}"