require 'xmlrpc/client'

host = XMLRPC::Client.new('E5-05-11', '/RPC2', 50510).proxy('gameshost')
puts host.register_client(1, 1, 'adfs',123)
