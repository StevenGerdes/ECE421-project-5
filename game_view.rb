require 'gtk2'
require './game_main'
require './game_state'

class GameView
  def initialize(game)
    Gtk.init

    @builder = Gtk::Builder::new
    @builder.add_from_file('game_view.glade')
    @builder.connect_signals { |handler| method(handler) } # (No handlers yet, but I will have eventually)

    window = @builder.get_object('mainWindow')
    window.signal_connect('destroy') { Gtk.main_quit }
    window.title = game.title

    @builder.get_object('ResetButton').signal_connect('clicked') { game.reset }
    @builder.get_object('SaveButton').signal_connect('clicked') { game.save_game }

    @picture_grid = @builder.get_object('play_grid')

    game.on_change.listen {
	  update_ui
    }

    game.on_win.listen { |winner|
      md = Gtk::MessageDialog.new(window, :destroy_with_parent, :info, :close, "player #{winner} wins")
      md.run
      md.destroy
    }

    @game_board = Hash.new
    @game = game
    
	(0..@game.columns - 1).each { |col|
      @builder.get_object("col#{col}").signal_connect('clicked') {
        game.play(col)
      }
      (0..@game.rows - 1).each { |row|
        @game_board[[row, col]] = @builder.get_object("#{row}_#{col}")
      }
    }
    @player_turn = @builder.get_object('PlayerNumber')
    @player_turn.text = game.player_turn.to_s
    window.show()
    Gtk.main()
  end

  def update_ui
	@player_turn.text = @game.player_turn.to_s
	strgs = @game.game_state_string
	puts strgs
	splittokens = strgs.split(//)
	for i in 0..5
		for j in 0..6
			token = splittokens[i*(7) + j]
			if token == '-'
	   	       current_image = Gtk::Stock::MEDIA_STOP
	   	     elsif token == 'r'
	   	       current_image = Gtk::Stock::NO
	   	     elsif token == 'g'
    	      current_image = Gtk::Stock::YES
    	   	 elsif token == 't'
        	  current_image = Gtk::Stock::ADD
	       	 elsif token == 'o'
    	   	   current_image = Gtk::Stock::CDROM
     	  	 end
			@game_board[[5-i, j]].set(current_image, Gtk::IconSize::BUTTON)
		end
	end
=begin
	(0..gs.columns - 1).each { |col|
      (0..gs.rows - 1).each { |row|
        token = gs.get_token(Coordinate.new(row, col))
=end
     # }
    #}
  end
end
