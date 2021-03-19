module Nowpayments
  class Configuration
    attr_accessor :version,
      :mode, :sandbox_uri, :production_uri,
      :api_key, :callback_uri

    def initialize
      @version = 1
      @mode = 'sandbox'
      @sandbox_uri = 'https://api.sandbox.nowpayments.io'
      @production_uri = 'https://api.nowpayments.io'
      @api_key = ''
      @callback_uri = ''
    end

    def base_uri
      if @mode == 'sandbox'
        @sandbox_uri
      else
        @production_uri
      end
    end

    def uri
      [base_uri, "v#{@version}"].join('/')
    end
  end
end
