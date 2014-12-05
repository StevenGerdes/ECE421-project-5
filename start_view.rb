require 'gtk2'
require './game_main'
class StartView

  def initialize(game_main)
    Gtk.init

    @builder = Gtk::Builder::new
    @builder.add_from_file('start_view.glade')
    @builder.connect_signals { |handler| method(handler) } # (No handlers yet, but I will have eventually)
	@builder.get_object('quit_button').signal_connect('activate'){Gtk.main_quit}
    window = @builder.get_object('mainWindow')
    window.signal_connect('destroy') { Gtk.main_quit }

    open_games_view = @builder.get_object('open_game_list')
	renderer = Gtk::CellRendererText.new
	column = Gtk::TreeViewColumn.new("Host Name", renderer, :text => 0)
	open_games_view.append_column(column)
	column = Gtk::TreeViewColumn.new("Game Type", renderer, :text => 1)
	open_games_view.append_column(column)
	
	open_games_view.model = Gtk::ListStore.new(String, String)

	refresh_games_list = Proc.new{
			game_main.open_games_list.each{ |item|
			row = open_games_view.model.prepend
			row[0] = item[:user1]
			row[1] = item[:game_type]
		}
	}
	
	refresh_games_list.call()

	refresh_button = @builder.get_object('refresh_button').signal_connect('clicked'){
		refresh_games_list.call()
	}

	#refresh_games_list.call()

	play_button = @builder.get_object('play_button')

	name_field = @builder.get_object('name_entry')
	name_field.signal_connect('changed'){ 	
		if name_field.text == ''
			play_button.sensitive = false
		else
			play_button.sensitive = true
		end
	}

    connect4 = @builder.get_object('connect_4')
    one_player = @builder.get_object('one_player')
	play_button.signal_connect("clicked") {
      if (connect4.active?)
        type = :connect4
      else
        type = :otto_toot
      end

      if (one_player.active?)
        players = 1
      else
        players = 2
      end

		name = name_field.text
      game_main.create_game( name, players, type )
	  }
	
    window.show()
    Gtk.main()
  end
end
