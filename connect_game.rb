require './contract'
require './game_state'

class ConnectGame
  include Contract

  attr_reader :game_state, :title, :on_win, :on_quit, :on_play

  class_invariant([lambda { |obj| obj.on_win.is_a?(SimpleEvent) },
                   lambda { |obj| obj.on_quit.is_a?(SimpleEvent) },
                   lambda { |obj| obj.on_play.is_a?(SimpleEvent) }])

  method_contract(
      #preconditions
      [lambda { |obj, title, game_state, players| title.respond_to?(:to_s) },
       lambda { |obj, title, game_state, players| game_state.respond_to?(:height) },
       lambda { |obj, title, game_state, players| game_state.respond_to?(:play) },
       lambda { |obj, title, game_state, players| game_state.respond_to?(:column_full?) },
       lambda { |obj, title, game_state, players| game_state.respond_to?(:player_turn) },
       lambda { |obj, title, game_state, players| game_state.respond_to?(:players) },
       lambda { |obj, title, game_state, players| game_state.respond_to?(:reset) },
       lambda { |obj, title, game_state, players| game_state.respond_to?(:change_turn) },
       lambda { |obj, title, game_state, players| players.respond_to?(:each) },
       lambda { |obj, title, game_state, players| players.respond_to?(:count) },
       lambda { |obj, title, game_state, players| players.count == game_state.players },
       lambda { |obj, title, game_state, players| players.count == 0 || players[0].respond_to?(:token_generator) },
       lambda { |obj, title, game_state, players| players.count == 0 || players[0].respond_to?(:win_condition) }],
      #postconditions
      [])
  #initializes the connect game
  def initialize(title, game_state, players)
    @on_win = SimpleEvent.new
    @on_quit = SimpleEvent.new
    @on_play = SimpleEvent.new
    @title = title.to_s
    @game_state = game_state
    @players = players
  end

  method_contract(
      #preconditions
      [lambda { |obj, column| column.respond_to?(:to_i) }],
      #postconditions
      [])
  #plays for the current player in the specified column if it is possible
  #if it isn't possible it does nothing
  def play(column)
    column = column.to_i
    unless @game_state.column_full?(column)
      @game_state.play(@players[@game_state.player_turn - 1].token_generator.get_token, Coordinate.new(@game_state.height(column), column))
      @on_play.fire

      winner = false
      @players.each_with_index { |player, index|
        if player.win_condition.check_win(game_state)
          winner = true
          @on_win.fire(index + 1)
        end
      }
      if winner
        @game_state.reset
      elsif !@game_state.is_full?
        @game_state.change_turn
      end

    end
  end

end
