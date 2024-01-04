#!/usr/bin/env perl

use lib '.';
use strict;
use warnings;
use Data::Dumper;
use POSIX;

use Time::HiRes qw(gettimeofday);

use BinanceAPI qw(
    rest_api
);


###############################################################################################
# Global variables
###############################################################################################
    my ($endpoint,$parameters,$api,$method,$result,$ping);
    my $apikey      = {
        "apikey"    => "",
        "apisecret" => ""
    };
    my $loglevel = 7;
###############################################################################################
#
# Sample commands
#
# Be careful using the code. Careless use of the subs below can result in a loss of money!
#
# Read additional (official) information here: https://binance-docs.github.io/apidocs/spot/en/
#
###############################################################################################
#
#GET COMMANDS
#
###############################################################################################
#
#GET /api/v3/ping
#
#    $endpoint   = "https://api.binance.com/api/v3/ping";
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v3/time
#
#    $endpoint = "https://api.binance.com/api/v3/time";
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, undef, undef, "GET", $loglevel-1);
#    if (defined $result) {
#        print strftime "Server time: %Y-%m-%d %H:%M:%S\n", localtime int($result->{serverTime}/1000);
#    } else {
#        print "Server time: undefined\n";
#    }
#
#GET /api/v3/exchangeInfo
#
#    $endpoint = "https://api.binance.com/api/v3/exchangeInfo";
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v3/symbolType
#
#    $endpoint = "https://api.binance.com/api/v3/symbolType";
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v3/ticker/bookTicker
#
#    $endpoint = "https://api.binance.com/api/v3/ticker/bookTicker";
#    ($result, $ping) = rest_api($endpoint, undef, undef, "GET", $loglevel-1);
#    print Dumper $result;
#
#GET /api/v3/ticker/bookTicker?symbol=string
#
#    $endpoint   = "https://api.binance.com/api/v3/ticker/bookTicker";
#    $method     = "GET";
#    $parameters = "symbol=BTCUSDT";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v3/klines
#
#Intervals:
#m -> minutes; h -> hours; d -> days; w -> weeks; M -> months
#Possible values: 1m,3m,5m,15m,30m,1h,2h,4h,6h,8h,12h,1d,3d,1w,1M
#Limit: Default 500; max 1000 (not required value)
#
#    $endpoint   = "https://api.binance.com/api/v3/klines";
#    $parameters = "symbol=BTCUSDT&interval=1h&limit=10";
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v3/ticker/24hr
#
#    $endpoint   = "https://api.binance.com/api/v3/ticker/24hr";
#    $parameters = "symbol=BTCUSDT&interval=1h&limit=10";
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v3/depth
#
#Limit: Default 500; max 1000 (not required value)
#
#    $endpoint   = "https://api.binance.com/api/v3/depth";
#    $parameters = "symbol=BTCUSDT&limit=10";
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v3/trades
#
#    $endpoint   = "https://api.binance.com/api/v3/trades";
#    $parameters = "symbol=BTCUSDT&limit=10";
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v3/aggTrades
#
#    $endpoint   = "https://api.binance.com/api/v3/aggTrades";
#    $parameters = "symbol=BTCUSDT&limit=10";
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v3/ticker/price
#
#    $endpoint   = "https://api.binance.com/api/v3/ticker/price";
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v3/ticker/price
#
#    $endpoint   = "https://api.binance.com/api/v3/ticker/price";
#    $parameters = "symbol=BTCUSDT";
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v3/account
#
#    $endpoint   = "https://api.binance.com/api/v3/account";
#    $api        = $apikey;
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v3/userTrades
#
#    $endpoint   = "https://api.binance.com/api/v3/userTrades";
#    $parameters = "symbol=BTCUSDT";
#    $api        = $apikey;
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v3/asset/tradeFee
#
#    $endpoint   = "https://api.binance.com/api/v3/asset/tradeFee";
#    $parameters = "symbol=BTCUSDT";
#    $api        = $apikey;
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v3/order
#
#    $endpoint   = "https://api.binance.com/api/v3/order";
#    $parameters = "symbol=BTCUSDT&origClientOrderId=KfHKsmFoTmTXQopvRa3xlP";
#    $api        = $apikey;
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v3/allOrders
#
#    $endpoint   = "https://api.binance.com/api/v3/allOrders";
#    $parameters = "symbol=BTCUSDT";
#    $api        = $apikey;
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v3/openOrders
#
#    $endpoint   = "https://api.binance.com/api/v3/openOrders";
#    $parameters = "symbol=BTCUSDT";
#    $api        = $apikey;
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v3/capital/deposit/address
#
#    $endpoint   = "https://api.binance.com/api/v3/capital/deposit/address";
#    $parameters = "coin=USDT&network=ETH";
#    $api        = $apikey;
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v3/capital/deposit/history
#
#    $endpoint   = "https://api.binance.com/api/v3/capital/deposit/history";
#    $api        = $apikey;
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v3/asset/transfer-history
#
#    $endpoint   = "https://api.binance.com/api/v3/asset/transfer-history";
#    $parameters = "type=MAIN_FUTURE";
#    $api        = $apikey;
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v3/capital/withdraw/history
#
#    $endpoint   = "https://api.binance.com/api/v3/capital/withdraw/history";
#    $api        = $apikey;
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
###############################################################################################
#
#POST COMMANDS
#
###############################################################################################
#
#POST /api/v3/order
#
#timeInForce: #GTC - Good Till Cancel #OC - Immediate or Cancel #FOK - Fill or Kill #GTX - Good Till Crossing (Post Only)
#
#    $endpoint   = "https://api.binance.com/api/v3/order";
#    $parameters = "symbol=BTCUSDT&side=BUY&type=LIMIT&timeInForce=GTC&quantity=0.0005&price=35000";
#    $api        = $apikey;
#    $method     = "POST";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
###############################################################################################
#
#DELETE COMMANDS
#
###############################################################################################
#
#DELETE /api/v3/order
#
#    $endpoint   = "https://api.binance.com/api/v3/order";
#    $parameters = "symbol=BTCUSDT&origClientOrderId=ukhWc5STnRTEYzy8lqpFk0";
#    $api        = $apikey;
#    $method     = "DELETE";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#DELETE /api/v3/openOrders
#
#    $endpoint   = "https://api.binance.com/api/v3/openOrders";
#    $parameters = "symbol=BTCUSDT";
#    $api        = $apikey;
#    $method     = "DELETE";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
###############################################################################################
#
# Subs
#
###############################################################################################
sub logmessage {
    my $string = $_[0];
    my $loglevel = $_[1];
    if ($loglevel >= 5 && $loglevel <= 10) { print $string; }
}
