require './contract'

class Connect4Checker
  include Contract

  class_invariant([])

  def initialize(value)
    @value = value
  end

  method_contract(
      #preconditions
      [lambda { |obj, game_state| game_state.respond_to?(:row) },
       lambda { |obj, game_state| game_state.respond_to?(:column) },
       lambda { |obj, game_state| game_state.respond_to?(:left_diagonal) },
       lambda { |obj, game_state| game_state.respond_to?(:right_diagonal) },
       lambda { |obj, game_state| game_state.respond_to?(:last_played) }],
      #postconditions
      [lambda { |obj, result, game_state| result.is_a?(TrueClass)|| result.is_a?(FalseClass) }])
  #given the current state of the game this will return true is it finds something that matches its win criteria
  def check_win(game_state)
    last_token = game_state.get_token(game_state.last_played)
    return !(last_token.nil?) &&
        (last_token.value == @value &&
            four_in_row(game_state.row(game_state.last_played.row)) ||
            four_in_row(game_state.column(game_state.last_played.column)) ||
            four_in_row(game_state.left_diagonal(game_state.last_played)) ||
            four_in_row(game_state.right_diagonal(game_state.last_played)))
  end

  method_contract(
      #preconditions
      [lambda { |obj, array| array.respond_to?(:each) }],
      #postconditions
      [lambda { |obj, result, array| result.is_a?(TrueClass) || result.is_a?(FalseClass) }])
  #checks if there are four tokens in a row with the same value as itself
  def four_in_row(array)
    num_in_row = 0
    array.each do |token|
      if !(token.nil?) && token.value == @value
        num_in_row += 1
        return true if num_in_row == 4
      else
        num_in_row = 0
      end
    end

    return false
  end


end
