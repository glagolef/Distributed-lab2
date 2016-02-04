require 'thread'
require 'socket'
# require 'openssl'
# require 'base64'
require './crypt_alg.rb'
$ticket
$session_key
$time
@MTU=1024*1024*10
threads = []
@files = 'files/'
successes = 0
rejections = 0

# 20.times do |i|
#   threads << Thread.new do
#     begin 
#       puts "Thread #{i} is requesting a socket"
#       socket = TCPSocket.open('127.0.0.1', 5000)
#       puts "Thread #{i} has connected to a socket"
#       socket.puts "HELO text\n"
#       puts "HELO message sent"
#       4.times do |j|
#         resp = socket.gets
#         puts "Got '#{resp.chomp}' from #{i}"
#       end
#       socket.close
#       successes += 1
#       puts "Thread #{i} has closed its connection"
#     rescue
#       puts "Could not establish a socket connection for t: #{i}"
#       rejections += 1
#     end
#   end
# end
# threads.each { |thr| thr.join }
# puts "Successes: #{successes.to_s}"
# puts "Rejections: #{rejections.to_s}"

def heloMsg(socket, message)
      msg ="#{$ticket}//" + encrypt(message, $session_key) 
      puts msg
      socket.puts msg 
      puts "#{message} sent"
      reply = ""
      while reply.chomp[-2..-1]!="=="
          reply << socket.gets
        end
      reply = decrypt(reply, $session_key)
      puts "Got '#{reply}'"
end
def readFile(filename, socket)
    file = @files + filename
        puts "Directory of file = #{file}" #this is the directory of file
        file_exist = File.exist?(file)
        puts "file exists = #{file_exist}"
        if !file_exist # add and if timestamp is older, or if file doesnt exist
          socket.puts "#{$ticket}//" + encrypt("read #{filename}\n", $session_key)
          if decrypt(socket.gets, $session_key) == "n/a\n"
            return "n/a"
          end
          puts "writing to file"
          theFile = File.open(file, "w")
          while chunk = decrypt(socket.read(@MTU), $session_key)
            puts "writing..."
            theFile.write(chunk)
          end
          theFile.close
          puts "File saved as #{file}"
        else 
        end
          theFile = File.open(file, "rb")
          return theFile
  end
  def writeFile(filename, socket, content)
    
    file = @files + filename
    theFile = File.open(file, "a+")
    theFile.write content
    theFile.close
    theFile = File.open(file, "rb")
    size = File.size(theFile)
    socket.puts encrypt("write #{filename} #{size}\n", $session_key)
    #ARE YOU READY?
    puts "server #{decrypt(socket.gets, $session_key)}"
    down_size = @MTU<size ? @MTU : size
    setback = down_size 
    puts down_size

    while down_size>0
      chunk = theFile.read(down_size)
      down_size = @MTU<size ? @MTU : size-setback
      setback += down_size
      puts "uploading..."
      socket.write encrypt(chunk + "\n", $session_key)
    end
    return decrypt(socket.gets, $session_key)
  end
  def login(username, password)
    as_socket = TCPSocket.open('127.0.0.1',5546)
    encr_message = encrypt("login #{username}", password)
    message = "#{username} #{encr_message}"
    as_socket.puts(message)
    rcv = ""
      while rcv.chomp[-2..-1]!="=="
        rcv << as_socket.gets
        puts rcv 
      end
    token = decrypt(rcv, password)
    as_socket.close
    return token
  end
  def logout

  end

def inputLoop(username, password, input)
  # loop do
        token = login(username, Digest::SHA1.hexdigest(password))
        puts token
        tck = "ticket:"
        sk = "session_key:"
        sv = "server"
        $ticket = token[/#{tck}(.*?)#{sk}/m, 1]
        $session_key = token[/#{sk}(.*?)#{sv}/m, 1]
        puts "ticket = #{$ticket}"
        puts "session_key = #{$session_key}"
        server = TCPSocket.open('127.0.0.1', 5001)
        # input = gets.chomp
        in_split = input.split
        command = in_split[0]
        file = in_split[1]
        content = input[in_split[0].length + in_split[1].length + 2..-1]
        if(!file.nil?)
          file = file.tr('\/:*?"<>| ', '')
        end
        file_not_empty = file != '' && !file.nil?
        content_not_empty = content != '' && !content.nil?
        if (command.start_with?("HELO"))
          heloMsg(server, input)
        elsif (command.start_with?("KILL_SERVICE"))
          server.puts "#{$ticket}//" + encrypt(input, $session_key)
          puts server.gets
        elsif(command == "read" or command == "write")
          if file_not_empty == false
            puts "No filename entered."
          else
            if (command=="read")
            fileToRead = readFile(file, server)
              if(fileToRead == "n/a") 
                puts "No such file found."
              else fileToRead.read end
            elsif(command == "write" && content_not_empty)
              puts writeFile(file, server, content)
            else end
          end
        else puts server.gets end
        server.close
  # end
end
#Hello
inputLoop("admin", "password", "HELO It's me")
#reading existing file
inputLoop("admin", "password","read README.md")
# #reading inexistent file
# inputLoop("read a.txt")
# #writing to an existing file
# inputLoop("write abc.txt  OOOOOOOOOO")
# #writing to an inexistent file
# inputLoop("write new_file abc de f g 1234 234rgkdfgnv;slk")
# #Kill service
# inputLoop("KILL_SERVICE die")