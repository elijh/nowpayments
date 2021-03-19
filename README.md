# NOWPayments

This is an experimental ruby binding for the NOWPayments API.

The definition of the API can be found here:
https://documenter.getpostman.com/view/7907941/T1LSCRHC

## Getting started

Create a NOWPayments account:

* Sandbox accounts: https://account.sandbox.nowpayments.io/create-account
* Production accounts: https://account.nowpayments.io/create-account

Through the nowpayments.io control panel, create an API key.

Configure the `api_key`:

    Nowpayments.configure do |config|
      config.mode = "production" # default is "sandbox"
      config.api_key = "0000000-XXXXXXX-1111111-YYYYYYY"
    end

## Usage

Return an array of accepted cryptocurrencies:

    Nowpayments.currencies

Get how much BTC to charge for the equivalent of $1000 USD:

    amount_in_btc = Nowpayments.estimate(
      currency_from: 'usd',
      amount: 1000,
      currency_to: 'btc'
    )

Create a new payment request:

    payment = Nowpayments.create_payment(
      amount: 1000,
      fiat: "usd",
      coin: "btc"
    )
    puts payment["payment_id"]     # eg "5231857091"
    puts payment["payment_status"] # eg "waiting"
    puts payment["pay_amount"]     # number of BTC (float)

Fetch a payment record:

    payment = Nowpayments.get_payment(5231857091)
    puts payment["payment_status"] # eg "confirmed"

The possible values for "payment_status" are:

    waiting
    confirming
    confirmed
    sending
    partially_paid
    finished
    failed
    refunded
    expired

## Instant Payment Notification

IPN is a callback that NOWPayments will make whenever the status
of a payment changes.

1. Log in to NOWPayments control panel.
2. Create a "secret_key"
3. Configure this gem for IPN.

For example:

    Nowpayments.configure do |config|
      config.callback_uri = "https://mydomain.org/ipn"
      config.secret_key = "ZDmmRht43euz7igFddUUKXsFZLvpfvcL"
    end

Where 'https://mydomain.org/ipn' is URI of your web application route to handle a POST callback from NOWPayments.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
