require './host_event_proxy'

client_proxy = HostEventProxy.new(1,nil)
Thread.new{
server = XMLRPC::Server.new(50501, ENV['HOSTNAME'])
server.add_handler(HostEventProxy::INTERFACE, client_proxy)
server.serve
}
