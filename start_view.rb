require 'gtk2'
require './game_main'
class StartView

  def initialize(game_main)
    Gtk.init

    @builder = Gtk::Builder::new
    @builder.add_from_file('start_view.glade')
    @builder.connect_signals { |handler| method(handler) } # (No handlers yet, but I will have eventually)

    window = @builder.get_object('window1')
    window.signal_connect('destroy') { Gtk.main_quit }

    connect4 = @builder.get_object('connect_4')
    one_player = @builder.get_object('one_player')

    @builder.get_object('play_button').signal_connect("clicked") {
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

      game_main.start_game(players, type)
    }

    window.show()
    Gtk.main()
  end
end