require 'xmlrpc/client'

class RClient

	def initialize(hostname, port, proxy_name)
		@hostname = hostname
		@port = port
		@proxy_name = proxy_name
		establish
	end
	
	def establish
		@proxy = XMLRPC::Client.new(@hostname, '/RPC2', @port).proxy(@proxy_name) 
	end

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
