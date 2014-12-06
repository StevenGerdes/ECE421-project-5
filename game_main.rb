require 'xmlrpc/client'

require './simple_event'
require './command_view'
require './connect_game_factory'
require './contract'
require './host_event_proxy'
require './r_client'

unless $DEBUG
  require './start_view'
  require './game_view'
end

class GameMain
  include Contract

  class_invariant([])
  #if it isn't debug this starts the game launcher
  def initialize
	@broker_proxy = RClient.new('E5-05-10', 50500, 'gamebroker')
    @game_list = []
	@port = 50500
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
	game_proxy = RClient.new(hostname, port, 'gameshost')
	client_proxy = HostEventProxy.new(game_id, game_proxy)

	pid = Thread.new{ 
		server = XMLRPC::Server.new(next_port, ENV['HOSTNAME'])
		server.add_handler(HostEventProxy::INTERFACE, client_proxy)
		server.serve
		true
	}
	@game_list.push({ :thread => pid, :id => game_id })
	game_proxy.register_client(game_id, 'bob', ENV['HOSTNAME'], 50501)	
	GameView.new(client_proxy)
  end
  
  def next_port
	@port+=1
	return @port
  end

  #Broker Proxy pass throughs
  def saved_game_list(name) @broker_proxy.saved_game_list(name) end
  def open_game_list() 		@broker_proxy.open_game_list 		end
  def stat_list() 			@broker_proxy.stat_list 			end

end
