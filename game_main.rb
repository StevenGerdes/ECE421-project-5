require './simple_event'
require './command_view'
require './connect_game_factory'
require './contract'

unless $DEBUG
  require './start_view'
  require './game_view'
end

class GameMain
  include Contract

  class_invariant([])
  #if it isn't debug this starts the game launcher
  def initialize
    StartView.new(self) unless $DEBUG
  end

  method_contract(
      #precondition
      [lambda { |obj, players, type| players.respond_to?(:to_i) },
       lambda { |obj, players, type| players.to_i > 0 },
       lambda { |obj, players, type| players.to_i <= 2 },
       lambda { |obj, players, type| type.is_a?(Symbol) }],
      #postcondition
      [])
  #Starts the game depending on the type and the number of players
  #if it isn't in debug mode it launches the game UI
  def start_game(players, type)
    game_factory = ConnectGameFactory.new(players.to_i, type)

    GameView.new(game_factory.connect_game, game_factory.game_state) unless $DEBUG

    CommandView.new(game_factory) if $DEBUG
  end


end
