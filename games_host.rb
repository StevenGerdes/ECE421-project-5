require 'xmlrpc/server'
require 'xmlrpc/client'

require './database'
require './connect_game_factory'
require './contract'

GameInfo = Struct.new(:connect_game, :game_state, :proxy)
class GamesHost
  include Contract

 class_invariant([])
  
  INTERFACE = XMLRPC::interface('gameshost'){
	meth 'int columns(id)'
	meth 'int rows(id)'
	meth 'struct get_token(id, coordinate)'
	meth 'int player_turn(id)'
	meth 'string title(id)'
  meth 'void play(id, column)'
  meth 'void reset(id)'
  meth 'void save_game(id)'
	meth 'void shutdown()'
	meth 'void create_game(gameid, players, type)'
  meth 'string register_client(id, player, hostname, port)'
  }


  def self.new_server(hostname, port)
	server = XMLRPC::Server.new(port, hostname)
	server.add_handler(GamesHost::INTERFACE, GamesHost.new)
	server.serve
  end

  def initialize
	@game_list = Hash.new
  end

  method_contract(
      #preconditions
      [],
      #preconditions
      [])

  def create_game(game_id, players, type)
	game_factory = ConnectGameFactory.new(players.to_i, type.to_sym)
	@game_list[game_id] = GameInfo.new(game_factory.connect_game, game_factory.game_state, nil)
	''
  end

  def register_client(game_id, player, hostname, port)
	game = @game_list[game_id]
	game.proxy = XMLRPC::Client.new(hostname,'/RPC2', port).proxy_async('hosteventproxy')
	
	game.game_state.on_change.listen{
	puts 'sent'
	Thread.new{
	game.proxy.on_change_fire
	puts 'done'
	}
	}

	game.connect_game.on_win.listen{ |winner|
		if(winner == player)
			game.proxy.on_win_fire
		end
	}
	puts 'registered'
	''
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
    @game_list[game_id].connect_game.play(column)
    ''
  end

  def reset(game_id)
    game_state(game_id).reset
  end

  def save_game(game_id)
    db = Database.new
    db.save_game(game_id, 'Tyler', 'Steven', game_state(game_id))
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

  def columns(id) 			game_state(id).columns 			end
  def rows(id) 				game_state(id).rows 			end
  def get_token(id, coord) 	game_state(id).get_token(coord)	end
  def player_turn(id)		game_state(id).player_turn		end
  def title(id)				
	type = game_state(id).type
	if(type == 'connect4')
		return 'Connect 4'
	else
		return 'OTTO TOOT'
  	end
  end
end
	
