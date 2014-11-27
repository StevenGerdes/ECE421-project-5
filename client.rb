require './contract'
require 'uri'
require 'xmlrpc/client'

class Client

  class_invariant([lambda{|obj| !obj.broker.nil?}])

  method_contract(
      #preconditions
      [lambda { |obj, url| url =~ /\A#{URI::regexp}\z/ }],
      #postconditions
      [lambda { |obj, result, url| obj.broker.respond_to?(:call) }])

  def initialize(user_name, url)
    @user_name = user_name
    @broker = XMLRPC::Client.new(url, '/RPC2')
  end

  method_contract(
      #preconditions
      [lambda { |obj, game_type| game_type.is_a?(Symbol) }],
      #postconditions
      [lambda { |obj, result, game_type| obj.host.respond_to?(:call) }])

  def create_game(game_type)
  end

  method_contract(
      #preconditions
      [lambda { |obj, game_id| game_id.respond_to?(:to_i) }],
      #postconditions
      [lambda { |obj, result, game_id| obj.host.respond_to?(:call) }])

  def join_game(game_id)
  end

  method_contract(
      #preconditions
      [lambda { |obj, coordinate, token| coordinate.respond_to?(:row) },
       lambda { |obj, coordinate, token| coordinate.respond_to?(:column) },
       lambda { |obj, coordinate, token| token.respond_to?(:value) }],
      #postconditions
      [])

  def play(token, coordinate)
  end

  method_contract(
      #preconditions
      [],
      #postconditions
      [lambda { |obj, result| result.respond_to?(:row) },
       lambda { |obj, result| result.respond_to?(:column) }])

  def last_played
  end

  method_contract(
      #preconditions
      [lambda { |obj, coordinate| coordinate.respond_to?(:row) },
       lambda { |obj, coordinate| coordinate.respond_to?(:column) }],
      #postconditions
      [lambda { |obj, result, coordinate| result.respond_to?(:value) }])

  def get_token(coordinate)
  end
end