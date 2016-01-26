require 'thread'
require 'socket'
class MultiThreadedServer
	def initialize
		puts "Initializing"
		# @ip_addr = "0.0.0.0"
		@ip_addr = '127.0.0.1'
		@thread_pool_size = 10
		@jobs = Queue.new
		@port = ARGV[0]
		@server = TCPServer.new(@ip_addr, @port)
		@student_id=12345678
		@terminate = false
		run
		# ip= Socket.ip_address_list.detect{|intf| intf.ipv4? and !intf.ipv4_loopback? and !intf.ipv4_multicast? and !intf.ipv4_private?}
		# puts "Listening on #{ip.ip_address}:#{port}"
		# thread_pool.add_workers(3)
		# puts thread_pool.workers_status
		# thread_pool.remove_workers(1)
		# puts thread_pool.workers_status
	# thread_pool.status_of_queue
# thread_pool.return_to_q
	end
	def run
		@ip_addr="134.226.44.149"
		puts "Running"
		#jobs queue
		Thread.new do
			loop do
				Thread.start(@server.accept) do |client|
					@jobs.push(client)
				end
			end
		end
		workers = (@thread_pool_size).times.map do
			Thread.new do
				begin
				while socket = @jobs.pop()
						puts "Connection accepted"
						request=socket.gets
						puts request
						a=manageRequest(request)
						puts a
						case a
						when 1
							socket.puts "#{request}IP:#{@ip_addr}\nPort:#{@port}\nStudentID:#{@student_id}\n"							
							socket.close
						when 0
							socket.close
							exit
						else
							socket.close
						end
					
				end
				rescue ThreadError
				#do nothing
				end
			end
	end
	# workers.map(&:join);

	end
	def manageRequest(request)
		if request.include?"KILL_SERVICE"
						@terminate = true
						return 0
		elsif request.include?"HELO"
						return 1
		else return -1
			puts "return null"
		end
	end
end
a = MultiThreadedServer.new

while !@terminate
end