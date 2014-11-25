require './contract'
require './connect4_checker'
require './token_generator'
require './game_state'
require './opponent'
require './connect_game'
require './pattern_checker'

class ConnectGameFactory

  include Contract

  attr_reader :player_count

  class_invariant([lambda{|obj| obj.player_count >= 0}])

  PlayerModel = Struct.new(:token_generator, :win_condition)

  method_contract(
      #preconditions
      [lambda{|obj, players, mode| players.respond_to?(:to_i)},
       lambda{|obj, players, mode| mode.is_a?(Symbol)}],
      #postconditions
      [])

  def initialize(players, mode)
    @player_count = 2
    @mode = mode
    @titles = {:connect4 => 'Connect Four', :otto_toot => 'OTTO TOOT'}
    @game_mode = Hash.new
    @game_mode[:connect4] = [
        PlayerModel.new(TokenGenerator.new('FF0000', 'r'), Connect4Checker.new('r')),
        PlayerModel.new(TokenGenerator.new('0000FF', 'g'), Connect4Checker.new('g'))]
    @game_mode[:otto_toot] = [
        PlayerModel.new(TokenGenerator.new('FF0000', 'o'), PatternChecker.new(['o','t','t','o'])),
        PlayerModel.new(TokenGenerator.new('0000FF', 't'), PatternChecker.new(['t','o','o','t'])),
    ]


    if players.to_i == 1
      init_opponent
    end
  end

  #singleton getter for a connect game
  def connect_game
    @connect_game = ConnectGame.new(@titles[@mode], game_state, @game_mode[@mode]) if @connect_game.nil?
    @connect_game
  end


  method_contract(
      #preconditions
      [lambda { |obj, player_num| player_num.respond_to?(:to_i) },
       lambda { |obj, player_num| player_num.to_i >= 1 },
       lambda { |obj, player_num| player_num.to_i <= obj.player_count }],
      #postconditions
      [lambda { |obj, result, player_num| result.respond_to?(:get_token) }])
  #getter for a players token generator
  def player_token_generator(player_num)
    @game_mode[@mode][player_num.to_i - 1].token_generator
  end

  method_contract(
      #preconditions
      [lambda { |obj, player_num| player_num.respond_to?(:to_i) },
       lambda { |obj, player_num| player_num.to_i >= 0 },
       lambda { |obj, player_num| player_num.to_i <= obj.player_count }],
      #postconditions
      [lambda { |obj, result, player_num| result.respond_to?(:check_win) }])
  #getter for win codition checker
  def player_win_condition_checker(player_num)
    @game_mode[@mode][player_num.to_i - 1].win_condition
  end

  #getter for all win condition checkers
  def player_win_condition_checkers
    (1..@player_count).map { |player| player_win_condition_checker(player) }
  end

  #getter for all token generators
  def player_token_generators
    (1..@player_count).map { |player| player_token_generator(player) }
  end

  #getter for game state
  def game_state
    if @game_state.nil?
      @game_state = GameState.new(@player_count, 6, 7)
    end
    @game_state
  end

  private

  #creates a new opponent
  def init_opponent
    Opponent.new(connect_game, game_state)
  end


end
