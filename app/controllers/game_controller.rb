class GameController < WebsocketRails::BaseController
  def initialize_session
    controller_store[:players] = []
    controller_store[:clicks] = 0
  end

  def client_connected
    controller_store[:players].push client_id
    cnt = controller_store[:players].count

    if cnt == 2
      broadcast_message :new_message, {
          received: Time.now.to_s(:short),
          msg_body: "Game started"
      }
      connection_store[:self] = client_id
      connection_store[:opp] = controller_store[:players][0]
      puts "OPP: #{connection_store[:opp]}"

      controller_store[:players].clear
    end

    private_channel(client_id).make_private

    broadcast_message :please_subscribe, "#{client_id}_incoming"
    broadcast_message :new_message, {
        received: Time.now.to_s(:short),
        msg_body: "#{client_id} connected"
    }
  end

  def private_channel(client_id)
    WebsocketRails["#{client_id}_incoming".to_sym]
  end

  def clicked
    controller_store[:clicks] += 1
    puts "CLICKED: #{controller_store[:clicks]}, #{connection_store[:opp]}"
    private_channel(connection_store[:opp]).trigger :game_update, controller_store[:clicks]
  end

  def authorize_channels
    if message[:channel] == "#{client_id}_incoming"
      accept_channel
    else
      deny_channel "INCORRECT USER"
    end
  end
end