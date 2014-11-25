require './contract'

class PatternChecker
  include Contract

  class_invariant([])

  method_contract(
      #preconditions
      [lambda { |obj, pattern| pattern.is_a?(Array) }],
      #postconditions
      [])

  def initialize(pattern)
    @pattern = pattern
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

  def check_win(game_state)
    return pattern_exists?(game_state.row(game_state.last_played.row)) ||
        pattern_exists?(game_state.column(game_state.last_played.column)) ||
        pattern_exists?(game_state.left_diagonal(game_state.last_played)) ||
        pattern_exists?(game_state.right_diagonal(game_state.last_played))
  end

  method_contract(
      #preconditions
      [lambda { |obj, array| array.is_a?(Array) }],
      #postconditions
      [])

  def pattern_exists?(array)
    array.join(' ').include?(@pattern.join(' '))
  end


end