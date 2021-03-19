require_relative "nowpayments/version"
require_relative "nowpayments/configuration"
require "httparty"

module Nowpayments
  class Error < StandardError
  end

  def self.configure
    yield(configuration) if block_given?
  end

  def self.configuration
    @configuration ||=  Configuration.new
  end

  def self.endpoint(path)
    [configuration.uri, path].join('/')
  end

  def self.get(cmd, params={})
    url = endpoint(cmd)
    headers = {'x-api-key': configuration.api_key}
    response = HTTParty.get(url, query: params, headers: headers)
    if response.success?
      return response
    else
      raise Nowpayments::Error, (response['message'] || response.response.msg)
    end
  end

  def self.post(cmd, params={})
    url = endpoint(cmd)
    headers = {
      "x-api-key" => configuration.api_key,
      "Content-Type" => "application/json"
    }
    response = HTTParty.post(url, body: params.to_json, headers: headers)
    if response.success?
      return response
    else
      raise Nowpayments::Error, (response['message'] || response.response.msg)
    end
  end

  public

  def self.status
    response = HTTParty.get(endpoint('status'))
    return response['message']
  end

  def self.currencies
    response = get('currencies')
    return response['currencies']
  end

  def self.estimate(amount:, currency_from: 'usd', currency_to:)
    response = get('estimate',
      amount: amount,
      currency_from: currency_from,
      currency_to: currency_to
    )
    if response.success?
      response["estimated_amount"]
    else
      nil
    end
  end

  #
  #  amount: amount to charge in fiat currency
  #  fiat: the symbol of the currency for amount
  #  coin: what cryptocurrency the user will pay in
  #  order: arbitrary string to attach to payment record (option)
  #  test: either nil, "fail", or "partially_paid". for testing responses.
  #
  def self.create_payment(amount:nil, fiat:nil, coin:nil, order:nil, test:nil)
    params = {
      "price_amount" => amount,
      "price_currency" => fiat,
      "pay_currency" => coin
    }
    if order
      params["order_id"] = order
    end
    if test
      params["case"] = test
    end
    if configuration.callback_uri && configuration.callback_uri != ""
      params["ipn_callback_url"] = configuration.callback_uri
    end
    response = post('payment', params)
    return response
  end

  def self.get_payment(id)
    get("payment/#{id.to_i}")
  end
end
