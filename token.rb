require './contract'

class Token
  include Contract

  attr_accessor :color, :selected
  attr_reader :value

  class_invariant([])

  method_contract(
      #preconditions
      [lambda { |obj, value, color| value.respond_to?(:to_s) },
       lambda { |obj, value, color| color.to_s.length == 6 },
       lambda { |obj, value, color| !color[/\H/] }],
      #postconditions
      [])

  def initialize(value, color)
    @value = value.to_s
    @color = color.to_s
  end

  def to_s
    @value.to_s
  end
end