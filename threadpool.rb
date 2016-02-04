require 'socket'
class Threadpool
	def initialize(server)
		@thread_pool_size = 1
		@a = server
		@jobs = Queue.new
		@server = TCPServer.new($ip_addr, $port)
		run
	end
		def run
		puts "Running"
		#jobs queue
		Thread.new do
			loop do
				Thread.start(@server.accept) do |client|
					puts "new job"
					@jobs.push(client)
				end
			end
		end
		workers = (@thread_pool_size).times.map do
			Thread.new do
				begin
				while true
					if(!@jobs.empty?)
						puts "job"
						@a.handleRequest(@jobs.pop)
					else 
						# puts "sleeeping"
						sleep (1)
					end
				end
				rescue ThreadError
				#do nothing
				end
			end
		end
	workers.map(&:join);
	end
end