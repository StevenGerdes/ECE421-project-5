require 'gtk2'
require './game_main'

class GameView

  def initialize(game, game_state)
    Gtk.init

    @builder = Gtk::Builder::new
    @builder.add_from_file('game_view.glade')
    @builder.connect_signals { |handler| method(handler) } # (No handlers yet, but I will have eventually)

    window = @builder.get_object('mainWindow')
    window.signal_connect('destroy') { Gtk.main_quit }
    window.title = game.title
    menu = @builder.get_object('ResetButton')
    menu.signal_connect('clicked') {
      game_state.reset }

    @picture_grid = @builder.get_object('play_grid')

    game_state.on_change.listen {
      update_ui(game_state)
    }

    game.on_win.listen { |winner|
      md = Gtk::MessageDialog.new(window, :destroy_with_parent, :info, :close, "player #{winner} wins")
      md.run
      md.destroy
    }

    @game_board = Hash.new
    @game_state = game_state
    (0..@game_state.columns - 1).each { |col|
      @builder.get_object("col#{col}").signal_connect('clicked') {
        game.play(col)
      }
      (0..@game_state.rows - 1).each { |row|
        @game_board[[row, col]] = @builder.get_object("#{row}_#{col}")
      }
    }
    @player_turn = @builder.get_object('PlayerNumber')
    @player_turn.text = @game_state.player_turn.to_s
    window.show()
    Gtk.main()
  end

  def update_ui(game_state)
    @player_turn.text = game_state.player_turn.to_s
    (0..@game_state.columns - 1).each { |col|
      (0..@game_state.rows - 1).each { |row|
        token = @game_state.get_token(Coordinate.new(row, col))
        if token.nil?
          current_image = Gtk::Stock::MEDIA_STOP
        elsif token.value == 'r'
          current_image = Gtk::Stock::NO
        elsif token.value == 'g'
          current_image = Gtk::Stock::YES
        elsif token.value == 't'
          current_image = Gtk::Stock::ADD
        elsif token.value == 'o'
          current_image = Gtk::Stock::CDROM
        end

        @game_board[[row, col]].set(current_image, Gtk::IconSize::BUTTON)
      }
    }
  end
end