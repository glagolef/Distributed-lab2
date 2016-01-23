require 'socket'
require 'thread'

threads = []

successes = 0
rejections = 0

10000.times do |i|
  threads << Thread.new do
    begin 
      puts "Thread #{i} is requesting a socket"
      socket = TCPSocket.open('127.0.0.1', 5000)
      puts "Thread #{i} has connected to a socket"
      if i==10000
        socket.puts "KILL_SERVICE\n"
      end
      socket.puts "HELO text\n"
      puts "HELO message sent"
#      socket.sleep(4)
      4.times do |j|
        resp = socket.gets
        puts "Got '#{resp.chomp}' from #{i}"
      end
      socket.close
      successes += 1
      puts "Thread #{i} has closed its connection"
    rescue
      puts "Could not establish a socket connection for t: #{i}"
      rejections += 1
    end
  end
end

threads.each { |thr| thr.join }

puts "Successes: #{successes.to_s}"
puts "Rejections: #{rejections.to_s}"