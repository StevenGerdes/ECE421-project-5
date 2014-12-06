require './simple_event'

class HostEventProxy
 
 	attr_reader :on_change, :on_win
	
	INTERFACE = XMLRPC::interface('hosteventproxy'){
		meth 'void on_change_fire()'
		meth 'void on_win_fire()'
	}

	def initialize(game_id, proxy)
		@host_proxy = proxy
		@on_change = SimpleEvent.new
		@on_win = SimpleEvent.new
		@id = game_id
	end

	def on_change_fire
		on_change.fire
		''
	end

	def on_win_fire
		on_win.fire
		''
	end

#Host proxy pass throughs
	def columns()			@host_proxy.columns(@id)			end
	def rows()				@host_proxy.rows(@id)				end
	def get_token(coord)	@host_proxy.get_token(@id, coord)	end
	def player_turn()		@host_proxy.player_turn(@id)		end
	def title()				@host_proxy.title(@id)				end
	def play(column) 		@host_proxy.play(@id, column)		end
end
