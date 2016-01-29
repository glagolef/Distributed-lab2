require 'thread'
require 'socket'
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
#       # if i==19
#       #   socket.puts "KILL_SERVICE\n"
#       # end
#       socket.puts "HELO text\n"
#       puts "HELO message sent"
# #      socket.sleep(4)
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

# #readWriteTest
# socket = TCPSocket.open('127.0.0.1', 5000)
# #read file
# input = "read crave_you.mp3"
# socket.puts input
# input = input.split

# File.open("c_y.mp3", "w") do |file|
#       while chunk = socket.read(@MTU)
#         file.write(chunk)
#       end
#         # file.close
#       puts "File received"
#     end
def readFile(filename, socket)
    file = @files + filename
        puts "Directory of file = #{file}" #this is the directory of file
        file_exist = File.exist?(file)
        puts "file exists = #{file_exist}"
        if !file_exist # add and if timestamp is older, or if file doesnt exist
          socket.puts "read #{filename}\n"
          puts "writing to file"
          theFile = File.open(file, "w")
          while chunk = socket.read(@MTU)
            puts "writing..."
            theFile.write(chunk)
            if(chunk.start_with"n/a")
              return "n/a"
            end
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
    socket.puts("write #{filename} #{size}\n")
    #ARE YOU READY?
    puts socket.gets
    down_size = @MTU<size ? @MTU : size
    setback = down_size 
              puts down_size

    while down_size>0
      chunk = theFile.read(down_size)
      down_size = @MTU<size ? @MTU : size-setback
      setback += down_size
      puts "uploading..."
      socket.write(chunk+ "\n")
      puts chunk
    end
    puts "OK"
      #   else 
      #     socket.puts("file on server is newer than yours")
      # end
    return socket.gets
  end
# write file
# input = "write crave_you.mp3"
# file = "c_y.mp3"
# file_exist = File.exist?(file)
# if  file_exist
#   timestamp = File.mtime(file)
#   socket.puts input + timestamp
#                 puts "opening file"
#                 fileContents = File.open(file, "rb")
#                 #   puts "writing file"
#                   while chunk = fileContents.read(@MTU)
#                     puts "sending file"
#                     socket.write(chunk)
#                   end
#                 # end
#                 # puts "writing file"
#                 # socket.write fileContents
#                 puts "file sent"
#                 socket.close
#               else 
#                 puts "No such #{file} file/directory"
#                 socket.puts "No such file / wrong directory to file"
#                 socket.close
#               end
# i


# socket.close
# def write(filename, socket)
#     file = @files + filename
#         puts file #this is the directory of file
#         file_exist = File.exist?(file)
#         puts file_exist
#         if  file_exist
#       fileContents = File.open(file, "rb")
#       while chunk = fileContents.read(@MTU)
#         socket.write(chunk)
#       end
#       puts "file sent"
#       socket.close
#     else 
#       puts "No such #{file} file/directory"
#       socket.puts "No such file / wrong directory to file"
#     end
#   end

  
def inputLoop(input)
  # loop do
        server = TCPSocket.open('127.0.0.1', 5001)
        # input = gets.chomp

        in_split = input.split
        command = in_split[0]
        file = in_split[1]
        content = input[in_split[0].length + in_split[1].length + 2..-1]
        #getting rid of special characters if present
        if(!file.nil?)
          file = file.tr('\/:*?"<>| ', '')
        end
        file_not_empty = file != '' && !file.nil?
        content_not_empty = content != '' && !content.nil?
        puts file_not_empty
        if (command.start_with?("HELO"))
          heloMsg(server, input)
        elsif (command.start_with?("KILL_SERVICE"))
          server.puts input
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
def heloMsg(socket, message)
      socket.puts input
      puts "#{message} sent"
      while resp = socket.gets
        puts "Got '#{resp.chomp}'"
      end
end
#reading existing file
inputLoop("read gay.txt")
#reading inexistent file
inputLoop("read a.txt")
#writing to an existing file
inputLoop("write abc.txt  OOOOOOOOOO")
#writing to an inexistent file
inputLoop("write new_file abc de f g 1234 234rgkdfgnv;slk")