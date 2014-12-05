require 'xmlrpc/client'
require './games_host'
proxy = XMLRPC::Client.new(ENV['HOSTNAME'], '/RPC2', 50501).proxy(GamesHost::I_NAME)

puts proxy.title(1);

