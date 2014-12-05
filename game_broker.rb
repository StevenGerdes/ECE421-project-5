require 'uri'
require 'xmlrpc/server'
require 'xmlrpc/client'
require './database'
require './contract'

ServerInfo = Struct.new(:hostname, :port, :proxy, :pid)

class GameBroker
	INTERFACE = XMLRPC::interface('gamebroker'){
		meth 'Array saved_game_list(String)'
		meth 'Array open_game_list()'
		meth 'Array stat_list()'
		meth 'void create_game(userName, players, type)'
		meth 'void join_game(int, string)'
		meth 'nil register_games_host(hostname, port)'
	}
  include Contract

 attr_reader :last_id, :server_list
  
  class_invariant([])

  method_contract(
      #preconditions
      [lambda { |this| ARGV[0].respond_to?(:to_i) }],
      #postconditions
      []
  )

  def initialize
    @last_id = -1;
	@open_game_list = []
	@server_list = []
  end

  method_contract(
      #preconditions
      [lambda { |this, user_name, player_count, game_type| user_name.respond_to?(:to_s) },
       lambda { |this, user_name, player_count, game_type| game_type.to_sym == :connect4 || game_type.to_sym == :otto_toot }],
      #postconditions
		[])
  def create_game(user_name, player_count, game_type)
  	@open_game_list.push({:id => gen_game_id, :user1 => user_name, :game_type => game_type})
  	
	server = get_open_server
	puts server.port
	return server.hostname, server.port, last_id 	
  end

  method_contract(
      #preconditions
      [lambda { |this, game_id, user2| game_id <= this.last_id }],
      #postconditions
      [lambda { |this, game_id, user2, host_url| host_url.respond_to?(:to_s) },
       lambda { |this, game_id, user2, host_url| nil == this.open_game_list.find{ |g| g[:id] == game_id } }]
  )

  def join_game(game_id, user2 )
  	@open_game_list.reject!{ |game| game[:id] == game_id }
	'www.google.ca'
  end
  
  def register_games_host(hostname, port)
	server_proxy = XMLRPC::Client.new(hostname, '/RPC2', port).proxy('gameshost')
	server_list.push( ServerInfo.new(hostname, port, server_proxy) )
  	puts "#{port} connected"
	'nil'
  end
	
  def open_game_list
		@open_game_list
  end
  
  def saved_game_list(user_name)
  db = Database.new
  result = db.get_saved_games_list(user_name)
  db.close
  result
  end

  def stat_list()
  db = Database.new
  result = db.get_stats
  db.close
  result
  end

  def kill_game_hosts
	puts 'killing'
	server_list.each{|server|
	begin
	server.proxy.shutdown
	rescue 
	end
	puts 'sent kill message'
	}
  end

  private
  def gen_game_id
    @last_id+=1
	return @last_id
  end

  def get_open_server
	return server_list.last 	
  end
	

end

game_broker = GameBroker.new
server = XMLRPC::Server.new(50500, ENV['HOSTNAME'])
server.add_handler(GameBroker::INTERFACE, game_broker)
server.serve
game_broker.kill_game_hosts
