require './contract'
require './token'

class TokenGenerator
  include Contract

  class_invariant([])

  def initialize(value)
    @value = value
  end

  method_contract(
      #preconditions
      [],
      #postconditions
       [lambda { |obj, result| result.respond_to?(:value) }])
  #returns a newly generated token
  def get_token
    return Token.new(@value)
  end

end
