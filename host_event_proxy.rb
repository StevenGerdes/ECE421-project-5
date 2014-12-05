require './simple_event'

class HostEventProxy
 
	def initialize(hostname, port, game_id)
		puts port
		@host_proxy = XMLRPC::Client.new(hostname, '/RPC2', port).proxy('gameshost')
		@host_proxy.test
		@host_proxy.register_client(game_id, 1, ENV['HOSTNAME'], port)
		@on_change = SimpleEvent.new
		@on_win = SimpleEvent.new
		@id = game_id
	end

	def on_change
		on_change.fire
	end

	def on_win
		on_win.fire
	end

#Host proxy pass throughs
	def columns()			@host_proxy.columns(@id)			end
	def rows()				@host_proxy.rows(@id)				end
	def get_token(coord)	@host_proxy.get_token(@id, coord)	end
	def player_turn()		@host_proxy.player_turn(@id)		end
	def title()				@host_proxy.title(@id)				end
	def play(column) 		@host_proxy.play(@id, column)		end
end
