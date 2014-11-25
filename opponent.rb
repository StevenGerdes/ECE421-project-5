require './contract'
class Opponent
  include Contract
  attr_reader :game_state

  class_invariant([lambda { |obj| !((obj.game_state).nil?) }])

  method_contract(
      #preconditions
      [lambda { |obj, connect_game, game_state| connect_game.respond_to?(:play) },
       lambda { |obj, connect_game, game_state| game_state.respond_to?(:on_turn_change) },
       lambda { |obj, connect_game, game_state| game_state.respond_to?(:player_turn) }],
      #postconditions
      [])

  def initialize(connect_game, game_state)
    @game_state = game_state
    game_state.on_turn_change.listen {
      if game_state.player_turn == 2
        connect_game.play(self.play)
      end
    }
  end

  method_contract(
      #preconditions
      [lambda { |obj| !((obj.game_state).is_full?) }],
      #postconditions
      [lambda { |obj, result| result.respond_to?(:to_i) },
       lambda { |obj, result| result.to_i < obj.game_state.columns }])

  #Chooses a column to play in at random for the AI
  def play
    result = rand(@game_state.columns - 1)
    while @game_state.column_full?(result)
      result = rand(@game_state.columns - 1)
    end

    return result
  end
end