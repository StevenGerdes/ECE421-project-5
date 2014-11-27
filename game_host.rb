require './contract'

class GameHost
  include Contract

  attr_reader num_active_games

  class_invariant([lambda{|this| this.num_active_games <= 10 },
                  lambda{|this| this.num_active_games >= 0 }])

  method_contract(
      #preconditions
      [lambda{|this, game_id| !game_id.nil?}],
      #preconditions
      [lambda{|this, game_id| this.num_active_games > 0},
       lambda{|this, game_id| !this.game_state(game_id).nil?}])

  def start_game(game_id)

  end

  method_contract(
      #preconditions
      [lambda{|this, game_id, column| !game_id.nil?},
       lambda{|this, game_id, column| column.respond_to?(:to_i)},
      lambda{|this, game_id, column| column.to_i >= 0},
      lambda{|this, game_id, column| column.to_i < this.game_state(game_id).columns }],
      #preconditions
      [])

  def play(game_id, column)

  end

  #getter for game state, no need for contracts
  def game_state(game_id)

  end
end