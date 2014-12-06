require 'xmlrpc/client'

host = XMLRPC::Client.new(ENV['HOSTNAME'], '/RPC2', 50501).proxy('hosteventproxy')
puts host.on_change_fire
