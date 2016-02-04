require 'thread'
# require 'openssl'
# require 'base64'
require 'securerandom'
require '../threadpool.rb'
require '../crypt_alg.rb'

# require '../crypt_alg.rb'
$terminate = false
$ip_addr = '127.0.0.1'
$port = 5546

class SecurityServer
	def initialize
		puts "Initializing"
		$client_data = Hash[*File.read('client_data').split(/[, \n]+/)]
		$server_data = Hash[*File.read('server_data').split(/[, \n]+/)]
		$login = { } 
	end
  	def encrypt(mess, passw)
    	cipher = OpenSSL::Cipher::AES.new(128, :ECB)
    	cipher.encrypt
    	cipher.key = passw
    	encr = cipher.update(mess) + cipher.final
    	encr64 = Base64.encode64(encr)
    	return encr64
  	end
  	def decrypt(mess, passw)
    	decipher = OpenSSL::Cipher::AES.new(128, :ECB)
    	decipher.decrypt
    	decipher.key = passw
    	decr64 = Base64.decode64(mess)
    	decr = decipher.update(decr64) + decipher.final
    	return decr
  	end

def login(username)
	session_key = SecureRandom.hex
	ticket = encrypt(session_key, $server_data['readWrite'])
	pre_token  = "ticket:#{ticket}session_key:#{session_key}server:readWritetime:#{60 * 60 * 90}"
	token = encrypt(pre_token, $client_data[username])
	puts token
	# puts ticket
	# puts "Sess key = #{session_key}"
	return token
end

def logout(username, session_id)

end


	def handleRequest(socket)
		puts "Connection accepted"
		time1 = Time.now + 1
		now = Time.now
		while now<=time1 && (request=socket.gets).nil?
			now = Time.now
		end
		if !request.nil?
			puts $client_data
			puts request
			req_array = request.split
			username = req_array[0]
			encrypted_message = req_array [1]
			decrypted_message = decrypt(encrypted_message, $client_data[username])
			puts decrypted_message
			decrypted_message = decrypted_message.split

			if (decrypted_message[0] == "login")
				if(username == decrypted_message[1])
					socket.puts(login(username))
				else socket.puts(encrypt("Wrong login details.",$client_data[username]))
				end
			elsif (command == "logout")
				#
        	else 
        	    socket.puts "bad input"
        	end
        else 
        	puts "Timeout"
        	socket.close
        end
	end
end

class MAIN
	threadpool = Threadpool.new(SecurityServer.new)

end
main = MAIN.new


# 	def writeToFile(file, username, password)
# 		theFile = File.open(file, "a")
# 	 	theFile.write("#{username}, #{Digest::SHA1.hexdigest(password)}\n")
# 	 	theFile.close
# 	end
# writeToFile("client_data", "admin", "password")
# writeToFile("client_data","user1", "qwerty12345")
# writeToFile("client_data","glagolef", "12308806")
# writeToFile("server_data", "readWrite", "read&write")