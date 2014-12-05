require './games_host'

host = ENV['HOSTNAME']
port = 50510

pid = fork{GamesHost.new_server(host, port)}
Process.detach(pid)


