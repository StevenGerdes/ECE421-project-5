require './games_host'

GamesHost.new_server(ENV['HOSTNAME'], 50501)
