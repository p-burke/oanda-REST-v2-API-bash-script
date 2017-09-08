
#OANDA REST-V20 API bash Shell Example

A simple bash client to access the [OANDA V2 Rest API](https://github.com/oanda/apidocs) using cURL.

Requires configuring to specify:
 - Account token, and
 - Account ID


----------
**This example is for use with the practice API and Demo accounts only. It should not be used with a Live account or the Live API**


----------


Supported commands:

* accounts - get a list of accounts
* trades - get a list of trades
* marketOrder new - create a new market order
* trade get - show individual trade information
* rate - show the current rate for a provided instrument

For information on how to create a test or live test account and obtain the authorization token goto [oanda.com](https://www.oanda.com/)

Required dependencies:

* Linux packages: curl, sed
* A fxTrade Demo Account

