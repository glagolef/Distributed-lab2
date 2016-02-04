require 'thread'
require '../threadpool.rb'
require '../crypt_alg.rb'

$terminate = false
$ip_addr = '127.0.0.1'
$port = ARGV[0]
$server_key = Digest::SHA1.hexdigest("read&write")
class MultiThreadedServer
	def initialize
		puts "Initializing"
		@student_id = 12345678
		@files = 'files/'
		@MTU=1024*1024*10
	end

	def handleRequest(socket)
		puts "Connection accepted"
    
		# time1 = Time.now + 1
		# now = Time.now
		# while now<=time1 && (request=socket.gets).nil?
		# 	now = Time.now
		# end
		request = ""
      	while request.chomp[-2..-1]!="=="
        	request << socket.gets
      	end
		if !request.nil?
			puts request
			#Split request
			req_array = request.split("//")
			puts req_array[0]
			session_key = decrypt(req_array[0], $server_key)
			request = decrypt(req_array[1], session_key)
			puts request
			req_array = request.split
			command = req_array[0]
			file = req_array [1]
			file_size = req_array[2]
			#execute command
			if command == "HELO"
				socket.puts encrypt("#{request}IP:#{$ip_addr}\nPort:#{$port}\nStudentID:#{@student_id}\n", session_key)
				socket.close
			elsif command == "KILL_SERVICE"
				socket.puts encrypt("Service Killed", session_key)
				socket.close
				$terminate = true
				exit
			elsif command == "disconnect"
				socket.close
			elsif (command == "read")
        	    readFile(file, socket, session_key)
			elsif (command == "write")
        	    writeFile(file, socket, session_key, file_size.to_i)
        	else 
        	    socket.puts encrypt("bad input", session_key)
        	end
        else 
        	puts "Timeout"
        	socket.close
        end
	end
	def readFile(filename, socket, session_key)
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
				socket.write encrypt(chunk, session_key)
			end
			puts "file sent"
			socket.close
		else 
			puts "No such #{filename} file"
			socket.puts encrypt("n/a", session_key)
		end
	end
	def writeFile(filename, socket, session_key, size)
		puts "writing"
		file = @files + filename
        puts file #this is the directory of file
        file_exist = File.exist?(file)
        puts "file exist = #{file_exist}"
			theFile = File.open(file, "a")
			down_size = (@MTU < size) ? @MTU : size
      		setback = down_size
		    socket.puts encrypt("ready", session_key)
      		while down_size>0
      			puts "writing..."
      			chunk = decrypt(socket.gets(down_size), session_key)
      			down_size = @MTU<size ? @MTU : size-setback
      			setback += down_size
        		theFile.write(chunk)
      		end
      		theFile.close
      		puts "File saved"
			socket.puts encrypt("OK", session_key)
			socket.close
	end
end

class MAIN
	threadpool = Threadpool.new(MultiThreadedServer.new)
end
main = MAIN.new