require 'xmlrpc/client'

require './simple_event'
require './command_view'
require './connect_game_factory'
require './contract'
require './host_event_proxy'

unless $DEBUG
  require './start_view'
  require './game_view'
end

class GameMain
  include Contract

  class_invariant([])
  #if it isn't debug this starts the game launcher
  def initialize
	@broker_proxy = XMLRPC::Client.new(ENV['HOSTNAME'], '/RPC2', 50500).proxy('gamebroker')
    StartView.new(self) unless $DEBUG
  end

  method_contract(
      #precondition
      [lambda { |obj, name,  players, type| players.respond_to?(:to_i) },
       lambda { |obj, name, players, type| players.to_i > 0 },
       lambda { |obj, name, players, type| players.to_i <= 2 },
       lambda { |obj, name, players, type| type.is_a?(Symbol) }],
      #postcondition
      [])
  #Starts the game depending on the type and the number of players
  #if it isn't in debug mode it launches the game UI
  def create_game(user_name, players, game_type)
	
	hostname, port, game_id = @broker_proxy.create_game(user_name, players, game_type)
   	puts port 
	host_proxy = HostEventProxy.new(hostname, port, game_id)
	GameView.new(host_proxy)
	Thread.new{ 
		server = XMLRPC::Server.new(port, ENV['HOSTNAME'])
		server.add_handler(HostEventProxy::INTERFACE, host_proxy)
		server.serve
	}

  end
  
  #Broker Proxy pass throughs
  def saved_game_list(name) @broker_proxy.saved_game_list(name) end
  def open_game_list() 		@broker_proxy.open_game_list 		end
  def stat_list() 			@broker_proxy.stat_list 			end

end
