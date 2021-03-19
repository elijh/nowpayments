require_relative "../lib/nowpayments"
require "minitest/autorun"
require "webmock/minitest"
require "vcr"

class NowpaymentsTest < Minitest::Test

  VCR.configure do |c|
    c.cassette_library_dir = "test/fixtures"
    c.hook_into :webmock
    c.allow_http_connections_when_no_cassette = true
  end

  def setup
    Nowpayments.configure do |config|
      config.api_key = "1234567-ABCDEFG-HIJKLMN-OPQRSTU"
    end
  end

  def test_status
    VCR.use_cassette('status') do
      r = Nowpayments.status
      assert_equal "OK", r
    end
  end

  def test_currencies
    VCR.use_cassette('currencies') do
      currencies = ["btg", "eth", "xmr", "btc", "zec", "xvg", "ada", "ltc", "bch", "dash", "xlm", "xrp", "dgb", "doge", "trx", "kmd", "bat", "eos", "waves", "tusd", "zen", "grs", "fun", "gas", "pax", "rvn", "bnbmainnet", "bcd", "usdterc20", "cro", "wabi", "busd", "stpt", "usdc"]
      response = Nowpayments.currencies
      assert_equal currencies.sort, response.sort
    end
  end

  def test_estimate
    VCR.use_cassette('estimate') do
      amount = Nowpayments.estimate(
        currency_from: 'usd',
        amount: 1000,
        currency_to: 'btc'
      )
      assert_equal 0.01698585, amount
    end
  end

  def test_create_payment
    VCR.use_cassette('payment1') do
      payment = Nowpayments.create_payment(
        amount: 1000,
        fiat: "usd",
        coin: "btc"
      )
      assert_equal "5231857091", payment["payment_id"]
      assert_equal "waiting", payment["payment_status"]
      assert_equal 0.01682986, payment["pay_amount"]
    end
  end

  def test_get_payment
    VCR.use_cassette('payment2') do
      payment = Nowpayments.get_payment("5231857091")
      assert_equal 5231857091, payment["payment_id"]
      assert_equal "confirmed", payment["payment_status"]
      assert_equal 0.01682986, payment["pay_amount"]
    end
  end

  def test_wrong_api_key
    VCR.use_cassette('invalid_api_key') do
      Nowpayments.configuration.api_key = "bogus"
      assert_raises Nowpayments::Error do |exc|
        Nowpayments.currencies
        assert_equal "Invalid access token", exc.to_s
      end
    end
  end
end
