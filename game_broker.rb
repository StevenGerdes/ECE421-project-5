require './contract'
require 'uri'
require 'xmlrpc/server'

class GameBroker
	INTERFACE = XMLRPC::interface('broker'){
		meth 'Array saved_games_list(String)'
		meth 'Array open_games_list()'
		meth 'Array game_stats()'
		meth 'void create_game(userName, players, type)'
		meth 'void join_game(int)'
	}
  include Contract

  attr_reader :open_games_list
  
  class_invariant([])

  method_contract(
      #preconditions
      [lambda { |obj| ARGV[0].respond_to?(:to_i) }],
      #postconditions
      []
  )

  def initialize
    @last_id = -1;
	@open_games_list = Array.new
  end

  method_contract(
      #preconditions
      [lambda { |obj, user_name, player_count, game_type| user_name.respond_to?(:to_s) },
       lambda { |obj, user_name, player_count, game_type| game_type.to_sym == :connect4 || game_type.to_sym == :otto_toot }],
      #postconditions
		[])
  def create_game(user_name, player_count, game_type)
  	puts user_name
  	@open_games_list.push(Hash.new(:id => gen_game_id, :user1 => user_name, :game_type => game_type))
  end

  method_contract(
      #preconditions
      [lambda { |obj, game_id| game_id <= obj.last_id },
       lambda { |obj, game_id| open_games_list.has_key(game_id) }],
      #postconditions
      [lambda { |obj, game_id, host_url| host_url =~ /\A#{URI::regexp}\z/ },
       lambda { |obj, game_id, host_url| !open_game_list.has_key(game_id) }]
  )

  def join_game(game_id)
  	@open_games_list.reject!{ |game| game.game_id == game_id }
  end

  method_contract( 
      #preconditions
      [lambda { |obj, user_name| user_name.respond_to?(:to_s)}],
      #postconditions
      [lambda { |obj, list| list.respond_to?(:each) },
       lambda { |obj, list| list.count == 0 || list[0].respond_to?(:type) },
       lambda { |obj, list| list.count == 0 || list[0].respond_to?(:player) },
       lambda { |obj, list| list.count == 0 || list[0].respond_to?(:create_date) }]
  )

  def saved_games_list(user_name)
	[Hash.new(:id => 1, :user1 => 'bob', :user2 => 'joe', :type => 'connect 4'),
	Hash.new(:id => 2,:user1 => 'bob', :user2 => 'donald', :type => 'otto toot')]
  end

  def game_stats()
	nil	
  end

  private
  def gen_game_id
    @last_id+=1
  end

end
	
server = XMLRPC::Server.new(50501, ENV['HOSTNAME'])
server.add_handler(GameBroker::INTERFACE, GameBroker.new)
server.serve
