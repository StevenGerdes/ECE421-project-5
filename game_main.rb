require './simple_event'
require './command_view'
require './connect_game_factory'
require './contract'
require 'xmlrpc/client'

unless $DEBUG
  require './start_view'
  require './game_view'
end

class GameMain
  include Contract

  class_invariant([])
  #if it isn't debug this starts the game launcher
  def initialize
	game_main_proxy = XMLRPC::Client.new(ENV['HOSTNAME'], '/RPC2', 50501).proxy('broker')
    StartView.new(game_main_proxy) unless $DEBUG
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
  def create_game(user_name, players, type)
    game_factory = ConnectGameFactory.new(players.to_i, type)

    GameView.new(game_factory.connect_game, game_factory.game_state) unless $DEBUG

    CommandView.new(game_factory) if $DEBUG
  end


end
