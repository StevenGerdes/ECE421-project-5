require 'xmlrpc/server'
require 'xmlrpc/client'

require './database'
require './connect_game_factory'
require './contract'
require './r_client'

GameInfo = Struct.new(:connect_game, :game_state, :proxy, :user1, :user2)
#this is server which hosts games
class GamesHost
  include Contract

  class_invariant([])

  INTERFACE = XMLRPC::interface('gameshost') {
    meth 'int columns(id)'
    meth 'int rows(id)'
    meth 'struct get_token(id, coordinate)'
    meth 'int player_turn(id)'
    meth 'string title(id)'
    meth 'coord last_played(id)'
    meth 'void play(id, column)'
    meth 'void reset(id)'
    meth 'void save_game(id)'
    meth 'void shutdown()'
    meth 'void create_game(user1, gameid, players, type)'
    meth 'void join_game(user2, gameid)'
    meth 'string game_board_string(id)'
    meth 'string register_client(id, player, hostname, port)'
  }

#used to init a server
  def self.new_server(hostname, port)
    server = XMLRPC::Server.new(port, hostname)
    server.add_handler(GamesHost::INTERFACE, GamesHost.new)
    server.serve

    true
  end

  def initialize
    @game_list = Hash.new
  end

  method_contract(
      #preconditions
      [],
      #preconditions
      [])
#uses the game factory to create the correct game models
  def create_game(user1, game_id, players, type)
    game_factory = ConnectGameFactory.new(players.to_i, type.to_sym)
    @game_list[game_id] = GameInfo.new(game_factory.connect_game, game_factory.game_state, nil, user1, nil)
    ''
  end

  #lets the second user join a game
  def join_game(user2, game_id)
    @game_list[game_id].user2 = user2
  end

  #sets the client side server so this can notify when the users turn has changed
  def register_client(game_id, player, hostname, port)
    game = @game_list[game_id]
    game.proxy = RClient.new(hostname, port, 'hosteventproxy')

    game.game_state.on_change.listen {
      Thread.new {
        game.proxy.on_change_fire
      }
    }

    game.connect_game.on_win.listen { |winner|
      if (winner == player)
        game.proxy.on_win_fire
      end
    }
    ''
  end

  method_contract(
      #preconditions
      [lambda { |this, game_id, column| !game_id.nil? },
       lambda { |this, game_id, column| column.respond_to?(:to_i) },
       lambda { |this, game_id, column| column.to_i >= 0 },
       lambda { |this, game_id, column| column.to_i < this.game_state(game_id).columns }],
      #preconditions
      [])
  #plays in the specific column for the specific game
  def play(game_id, column)
    @game_list[game_id].connect_game.play(column)
    ''
  end

  #resets the specific game
  def reset(game_id)
    game_state(game_id).reset
  end

  #saves the specific game to the database
  def save_game(game_id)
    db = Database.new
    user2 = @game_list[game_id].user2
    if user2.nil?
      user2 = ''
    end
    db.save_game(game_id, @game_list[game_id].user1, user2, game_state(game_id))
    db.close
    ''
  end

  #getter for game state, no need for contracts
  def game_state(game_id)
    @game_list[game_id].game_state
  end

  def shutdown
    exit!
  end
#game state passthroughs below
  def columns(id)
    game_state(id).columns
  end

  def rows(id)
    game_state(id).rows
  end

  def get_token(id, coord)
    game_state(id).get_token(coord)
  end

  def player_turn(id)
    game_state(id).player_turn
  end

  def last_played(id)
    game_state(id).last_played
  end
#converts the game_board to a string for easy quick transport
  def game_board_string(id)
    gs = game_state(id)
    result = ''
    (gs.rows - 1).downto(0) { |i|
      row_matrix = gs.row i
      for j in 0..gs.columns - 1
        if row_matrix[j].nil?
          result += '-'
        else
          result += row_matrix[j].value
        end
      end
    }
    return result
  end
#gets the title of the current game
  def title(id)
    type = game_state(id).type
    if (type == 'connect4')
      return 'Connect 4'
    else
      return 'OTTO TOOT'
    end
  end
end
	
