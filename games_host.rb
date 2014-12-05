require 'xmlrpc/server'
require 'xmlrpc/client'

require './contract'

class GamesHost
  include Contract

  class_invariant([lambda{|this| this.num_active_games <= 10 },
                  lambda{|this| this.num_active_games >= 0 }])
  
  INTERFACE = XMLRPC::interface('gameshost'){
	meth 'int columns(id)'
	meth 'int rows(id)'
	meth 'struct get_token(id, coordinate)'
	meth 'int player_turn(id)'
	meth 'string title(id)'
  	meth 'void shutdown()'
  }

  def self.new_server(hostname, port)
	server = XMLRPC::Server.new(port, hostname)
	server.add_handler(GamesHost::INTERFACE, GamesHost.new)
	server.serve
  end

  method_contract(
      #preconditions
      [lambda{|this, game_id| !game_id.nil?}],
      #preconditions
      [lambda{|this, game_id| this.num_active_games > 0},
       lambda{|this, game_id| !this.game_state(game_id).nil?}])

  def create_game(game_id, players, type)
	game_list[game_id]
	game_factory = ConnectGameFactory.new(players.to_i, type)
  end

  def register_client(game_id, player, hostname, port)
  	game = game_list[game_id]
	game.proxy = XMLRPC::Client.new(hostname,'/RPC2', port).proxy('client')
	
	game.game_state.on_change.listen{
		game.proxy.on_change
	}

	game.connect_game.on_win.listen{ |winner|
		if(winner == player)
			game.proxy.on_win
		end
	}
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

  end

  #getter for game state, no need for contracts
  def game_state(game_id)

  end
  
  def shutdown
  	exit!
  end

  def columns(id) 			game_state(id).columns 			end
  def rows(id) 				game_state(id).rows 			end
  def get_token(id, coord) 	game_state(id).get_token(coord)	end
  def player_turn(id)		game_state(id).player_turn		end
  def title(id)				
  	return 'blah'
	type = game_state(id).type
	if(type == 'connect4')
		return 'Connect 4'
	else
		return 'OTTO TOOT'
  	end
  end
end
	