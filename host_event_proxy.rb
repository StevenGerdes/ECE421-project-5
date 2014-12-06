require './simple_event'
require 'xmlrpc/server'

class HostEventProxy
 
 	attr_reader :on_change, :on_win
	
	INTERFACE = XMLRPC::interface('hosteventproxy'){
		meth 'void on_change_fire()'
		meth 'void on_win_fire()'
		meth 'void test()'
	}

	def initialize(game_id, proxy)
		@host_proxy = proxy
		@on_change = SimpleEvent.new
		@on_win = SimpleEvent.new
		@id = game_id
	end

	def test
		'adsf'
	end

	def on_change_fire
		puts 'ggg'
		@on_change.fire
		puts 'ddd'
		'aaa'
	end

	def on_win_fire
		on_win.fire
		''
	end

#Host proxy pass throughs
	def columns()			    @host_proxy.columns(@id)			    end
	def rows()				    @host_proxy.rows(@id)				      end
	def get_token(coord)	@host_proxy.get_token(@id, coord)	end
	def player_turn()		  @host_proxy.player_turn(@id)		  end
	def title()				    @host_proxy.title(@id)				    end
	def play(column) 		  @host_proxy.play(@id, column)		  end
  def reset()           @host_proxy.reset(@id)            end
  def save_game()       @host_proxy.save_game(@id)        end
end
