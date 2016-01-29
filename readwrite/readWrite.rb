require 'thread'
require '../threadpool.rb'
$terminate = false
$ip_addr = '127.0.0.1'
$thread_pool_size = 1
$port = ARGV[0]
class MultiThreadedServer
	def initialize
		puts "Initializing"
		@student_id = 12345678
		@files = 'files/'
		@MTU=1024*1024*10

	end

	def handleRequest(socket)
		puts "Connection accepted"
    

		time1 = Time.now + 1
		now = Time.now
		while now<=time1 && (request=socket.gets.chomp).nil?
			now = Time.now
		end
		if !request.nil?
			puts request
			req_array = request.split
			command = req_array[0]
			file = req_array [1]
			file_size = req_array[2]
			msg = manageRequest(request, socket)
			# puts msg
			#read
			if (msg!=0)
				#do nothing
			elsif (command == "read")
        	    readFile(file, socket)
			elsif (command == "write")
        	    writeFile(file, socket, file_size.to_i)
        	else 
        	    socket.puts "bad input"
        	end
        else 
        	puts "Timeout"
        	socket.close
        end
	end
	def manageRequest(request, client)
		if request.start_with?"HELO"
			client.puts "#{request}IP:#{$ip_addr}\nPort:#{$port}\nStudentID:#{@student_id}\n"
			client.close
		elsif request.start_with?"KILL_SERVICE"
			client.puts "Service Killed"
			client.close
			$terminate = true
			exit
		elsif request.start_with?"disconnect"
			client.close
		else return 0
		end
	end

	def readFile(filename, socket)
		puts "reading"
		file = @files + filename
        puts file #this is the directory of file
        file_exist = File.exist?(file)
        puts file_exist
        if  file_exist
        	puts "sending file"
			fileContents = File.open(file, "rb")
			while chunk = fileContents.read(@MTU)
				puts "sending ..."
				socket.write(chunk)
			end
			puts "file sent"
			socket.close
		else 
			puts "No such #{file} file/directory"
			socket.puts "No such file / wrong directory to file"
		end
	end
	def writeFile(filename, socket, size)
		puts "writing"
		file = @files + filename
        puts file #this is the directory of file
        file_exist = File.exist?(file)
        puts "file exist = #{file_exist}"
        # if !file_exist # add and if timestamp is older, or if file doesnt exist
			theFile = File.open(file, "a")
			puts "writing file"
			down_size = (@MTU < size) ? @MTU : size
      		setback = down_size
      		puts down_size
		    socket.puts "ready"
      		while down_size>0
      			puts "writing..."
      			chunk = socket.gets(down_size)
      			puts chunk
      			down_size = @MTU<size ? @MTU : size-setback
      			setback += down_size
        		theFile.write(chunk)
      		end
      		theFile.close
      		puts "File saved"
     #  	else 
     #  		socket.puts("file on server is newer than yours")
    	# end
			socket.puts"OK"
			socket.close
	end
	# workers.map(&:join);
end

class MAIN
	threadpool = Threadpool.new
	# threadpool.initialize
	while !$terminate
	end
end
main = MAIN.new