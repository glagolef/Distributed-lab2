require 'openssl'
require 'base64'
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