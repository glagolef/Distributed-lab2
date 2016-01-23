require 'thread'
class Thread_Pool
	def initialize(threads)
		puts "creating Thread_Pool"
		@threads_max = 20
		@threads_num = threads
		@workers = Queue.new
		@threads_num.times do |i|
			@workers << Thread.new{sleep}
		end
	end
	#adds new threads to queue
	def add_workers(n)
		n.times do 
			@workers<<Thread.new{sleep}
			@threads_num+=1
		end
	end
	#removes threads from queue
	def remove_workers(n)
		n.times do 
			a = @workers.pop
			a.kill
			@threads_num-=1
		end
	end
	#retrieves thread from queue to do some work
	def do_work
		if (!@workers.empty?())
			@threads_num-=1
			return @workers.pop
		end
		return 0
	end
	#returns thread back into queue
	def return_to_q(thr)
		@workers.push(thr)
		@threads_num+=1
	end
	#returns number of vacant workers in the pool
	def workers_status
		return @workers.length()
	end
	def status_of_queue
		@workers.length().times do |i|
			puts @workers.pop.status
		end
	end
	def shutdown
		@workers.length().times do
			@workers.pop.join
		end
	end
end



