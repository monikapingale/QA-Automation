=begin
************************************************************************************************************************************
    Author      :   QaAutomationTeam
    Description :   This gem ....

    History     :
  ----------------------------------------------------------------------------------------------------------------------------------
  VERSION           DATE             AUTHOR                  DETAIL
  1                 20 June 2018     QaAutomationTeam        Initial Developement
**************************************************************************************************************************************
=end


require 'encryptor'
require 'securerandom'
class EnziEncryptor
  
=begin
    ************************************************************************************************************************************
         Author           :   QaAutomationTeam
         Description      :   This method will ....
         Created Date     :   21 April 2018         
    **************************************************************************************************************************************
=end
  def self.encrypt(data,key)
    cipher = OpenSSL::Cipher.new('aes-256-gcm')
    cipher.encrypt
    @iv = cipher.random_iv
    @salt = SecureRandom.random_bytes(16)
    encrypted_value = Encryptor.encrypt(value: "#{data}", key: key, iv: @iv, salt: @salt)
    puts "cipher----->#{encrypted_value}$@$#{@iv}$@$#{@salt}"
    return "#{encrypted_value}$@$#{@iv}$@$#{@salt}"
  end

=begin
    ************************************************************************************************************************************
         Author           :   QaAutomationTeam
         Description      :   This method .....
         Created Date     :   21 April 2018
         Issue No.        :
    **************************************************************************************************************************************
=end
  def self.decrypt(encrypted_value,key)
    puts "encrypted_value-->#{encrypted_value}"
    encrypted_value = encrypted_value.split('$@$')[0]    
    iv = encrypted_value.split('$@$')[1]
    puts "iv-->#{iv}"    
    salt = encrypted_value.split('$@$')[2]
    puts "salt-->#{salt}"    
    decrypted_value = Encryptor.decrypt(value: encrypted_value, key: key, iv: iv, salt: salt)
  end

end #end of class




