require 'socket'
require './Thread_Pool.rb'
ip_addr = "0.0.0.0"
thread_pool = Thread_Pool.new(1)
port = ARGV[0]
server = TCPServer.new(ip_addr, port)
student_id=12345678
# ip= Socket.ip_address_list.detect{|intf| intf.ipv4? and !intf.ipv4_loopback? and !intf.ipv4_multicast? and !intf.ipv4_private?}
# puts "Listening on #{ip.ip_address}:#{port}"
# thread_pool.add_workers(3)
# puts thread_pool.workers_status
# thread_pool.remove_workers(1)
# puts thread_pool.workers_status
# thread_pool.status_of_queue
# thread_pool.return_to_q
loop do 
	begin
		vacant_workers = thread_pool.workers_status-1
		if(vacant_workers/1.5<1)
			add_workers(vacant_workers)
		elsif(vacant_workers/1.5>1)
			remove_workers(vacant_workers/2)
		end
			thr = thread_pool.do_work{
				socket=server.accept; 
				request=socket.gets;
				if(request.contains("HELO"))
					socket.puts("#{request}IP:#{ip_addr}\nPort:#{port}\nStudentID:#{student_id}\n")
				elsif (request.contains("KILL_SERVICE"))
					shutdown;
					Thread.join;
				else #donothing
				end
				socket.close;
				Thread.sleep}
	rescue
	#do nothing
	end
end
thr = thread_pool.do_work{puts "thread at work"; Thread.sleep}
puts thr.status
thread_pool.return_to_q(thr)
puts thr.status
# thread_pool.return_to_q(thr)
# thr.join
puts student_id
thread_pool.status_of_queue
# puts thread_pool.workers_status
def shutdown
	thread_pool.shutdown
	exit
end
