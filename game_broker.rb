require 'uri'
require 'xmlrpc/server'
require 'xmlrpc/client'
require './database'
require './contract'

ServerInfo = Struct.new(:hostname, :port, :proxy, :pid)
#this is the main server which hands things off to other servers

class GameBroker
  INTERFACE = XMLRPC::interface('gamebroker') {
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
    db = Database.new
    @last_id = db.get_game_id;
    db.close
    @open_game_list = []
    @server_list = []
  end

  method_contract(
      #preconditions
      [],
      #postconditions
      [])
  #starts a game on an open server and then returns that servers information and the game id
  def create_game(user_name, player_count, game_type)
    server = get_open_server
    @open_game_list.push({:id => gen_game_id, :user1 => user_name, :game_type => game_type, :server => server})
    server.proxy.create_game(user_name, last_id, player_count, game_type)

    return server.hostname, server.port, last_id
  end

  method_contract(
      #preconditions
      [lambda { |this, game_id, user2| game_id <= this.last_id }],
      #postconditions
      [lambda { |this, game_id, user2, host_url| host_url.respond_to?(:to_s) },
       lambda { |this, game_id, user2, host_url| nil == this.open_game_list.find { |g| g[:id] == game_id } }]
  )
  #finds the game matching the game id, then returns its server hosts information
  #and make user2 join the game. It also removes the game from the open games list
  def join_game(game_id, user2)
    server = @open_game_list[game_id][:server]
    @open_game_list.reject! { |game| game[:id] == game_id }
    server.proxy.join_game(user2, game_id)
    return server.hostname, server.port
  end

  #This regeisters the other 'servers' so that they can be used and kill appropriately
  def register_games_host(hostname, port)
    server_proxy = XMLRPC::Client.new(hostname, '/RPC2', port).proxy('gameshost')
    @server_list.push(ServerInfo.new(hostname, port, server_proxy))
    puts "#{port} connected"
    'nil'
  end

  #a list of open games with only one person
  def open_game_list
    @open_game_list
  end

  #A list of saved games for the current user
  def saved_game_list(user_name)
    db = Database.new
    result = db.get_saved_games_list(user_name)
    db.close
    result
  end

  #returns a list of statistics for the games
  def stat_list()
    db = Database.new
    result = db.get_stats
    db.close
    result
  end

  #kills all servers so they don't hang around
  def kill_game_hosts
    puts 'killing'
    @server_list.each { |server|
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
    return @server_list.first
  end


end

game_broker = GameBroker.new
server = XMLRPC::Server.new(50500, ENV['HOSTNAME'])
server.add_handler(GameBroker::INTERFACE, game_broker)
server.serve
game_broker.kill_game_hosts
