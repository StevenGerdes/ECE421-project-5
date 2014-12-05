require './games_host'

@broker = XMLRPC::Client.new(ENV['HOSTNAME'], '/RPC2', 50500).proxy('gamebroker')
host = ENV['HOSTNAME']

port = 50510
pid = fork{GamesHost.new_server(host, port)}
@broker.register_games_host(host, port)
Process.detach(pid)

port = 50520
pid = fork{GamesHost.new_server(host, port)}
@broker.register_games_host(host, port)
Process.detach(pid)

port = 50530
pid = fork{GamesHost.new_server(host, port)}
@broker.register_games_host(host, port)
Process.detach(pid)

port = 50540
pid = fork{GamesHost.new_server(host, port)}
@broker.register_games_host(host, port)
Process.detach(pid)

port = 50550
pid = fork{GamesHost.new_server(host, port)}
@broker.register_games_host(host, port)
Process.detach(pid)
