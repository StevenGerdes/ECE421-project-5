require 'xmlrpc/client'

game_main_proxy = XMLRPC::Client.new(ENV['HOSTNAME'], '/RPC2', 50501).proxy('broker')

game_main_proxy.open_games_list.each{ |item|

	puts item[:user1]

	}

