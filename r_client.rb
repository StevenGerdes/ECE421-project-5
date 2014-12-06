require 'xmlrpc/client'
#this is a reconnecting client. Clients often time out
#this solves that by re-establishing connections if it breaks
#if it breaks twice really close to each other then it still dies
class RClient

  def initialize(hostname, port, proxy_name)
    @hostname = hostname
    @port = port
    @proxy_name = proxy_name
    establish
  end

  #this re-establishes the connection
  def establish
    @proxy = XMLRPC::Client.new(@hostname, '/RPC2', @port).proxy(@proxy_name)
  end

  #this allows for calling any normal xmlrpc client method
  def method_missing(meth, *args, &block)
    begin
      @proxy.send(meth, *args, &block)
    rescue
      establish
      puts 'connect reestablished'
      @proxy.send(meth, *args, &block)
    end
  end
end
