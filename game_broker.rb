require './contract'
require 'uri'

class GameBroker
  include Contract

  class_invariant([])

  attr_reader current_id

  method_contract(
      #preconditions
      [lambda { |obj| ARGV[0].respond_to?(:to_i) }],
      #postconditions
      []
  )

  def initialize
    @last_id = -1;
  end

  method_contract(
      #preconditions
      [lambda { |obj, user_name, game_type| user_name.respond_to?(:to_s) },
       lambda { |obj, user_name, game_type| game_type == :connect4 || game_type == :otto_toot }],
      #postconditions
      [lambda { |obj, game_id, host_url| game_id == @last_id },
       lambda { |obj, game_id, host_url| host_url =~ /\A#{URI::regexp}\z/ }]
  )

  def create_game(user_name, game_type)

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

  end

  method_contract(
      #preconditions
      [],
      #postconditions
      [lambda { |obj, list| list.respond_to?(:each) },
       lambda { |obj, list| list.count == 0 || list[0].respond_to?(:type) },
       lambda { |obj, list| list.count == 0 || list[0].respond_to?(:player) }]
  )

  def open_games_list

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

  def save_games_list(user_name)

  end

  private
  def gen_game_id
    @last_id+=1
  end

end