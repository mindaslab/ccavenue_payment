require 'uri'
require_relative 'ccavenue_payment/config'
require_relative 'ccavenue_payment/crypto'

module CcavenuePayment
  class << self
    # Create request object
    # === Options(Hash)
    def encrypted_data(data)
      #query_string = data.merge!({ merchant_id: Config.merchant_id }).to_query
      query_string = hash_to_query(data.merge!({ merchant_id: Config.merchant_id }))
      crypto.encrypt(query_string)
    end

    def decrypted_data(encrypted_string)
      crypto.decrypt(encrypted_string)
    end

    def request_url
      if Config.mode.upcase == 'TEST'
        "https://test.ccavenue.com/transaction/transaction.do?command=initiateTransaction"
      elsif Config.mode.upcase == 'LIVE'
        "https://secure.ccavenue.com/transaction/transaction.do?command=initiateTransaction"
      end
    end

    def access_code
      @access_code ||= Config.access_code
    end

    private

    def crypto
      @crypto ||= Crypto.new(working_key: Config.working_key)
    end

    def hash_to_query(hash)
      CGI.escape(hash.map{|k,v| "#{k}=#{v}"}.join("&"))
    end
  end
end
