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
# Read additional (official) information here: https://www.commex.com/api-docs/en/
#
###############################################################################################
#
#GET COMMANDS
#
###############################################################################################
#
#GET /api/v1/ping
#
#    $endpoint   = "https://api.commex.com/api/v1/ping";
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v1/time
#
#    $endpoint = "https://api.commex.com/api/v1/time";
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, undef, undef, "GET", $loglevel-1);
#    if (defined $result) {
#        print strftime "Server time: %Y-%m-%d %H:%M:%S\n", localtime int($result->{serverTime}/1000);
#    } else {
#        print "Server time: undefined\n";
#    }
#
#GET /api/v1/exchangeInfo
#
#    $endpoint = "https://api.commex.com/api/v1/exchangeInfo";
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v1/symbolType
#
#    $endpoint = "https://api.commex.com/api/v1/symbolType";
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v1/ticker/bookTicker
#
#    $endpoint = "https://api.commex.com/api/v1/ticker/bookTicker";
#    ($result, $ping) = rest_api($endpoint, undef, undef, "GET", $loglevel-1);
#    print Dumper $result;
#
#GET /api/v1/ticker/bookTicker?symbol=string
#
#    $endpoint   = "https://api.commex.com/api/v1/ticker/bookTicker";
#    $method     = "GET";
#    $parameters = "symbol=BTCUSDT";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v1/klines
#
#Intervals:
#m -> minutes; h -> hours; d -> days; w -> weeks; M -> months
#Possible values: 1m,3m,5m,15m,30m,1h,2h,4h,6h,8h,12h,1d,3d,1w,1M
#Limit: Default 500; max 1000 (not required value)
#
#    $endpoint   = "https://api.commex.com/api/v1/klines";
#    $parameters = "symbol=BTCUSDT&interval=1h&limit=10";
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v1/ticker/24hr
#
#    $endpoint   = "https://api.commex.com/api/v1/ticker/24hr";
#    $parameters = "symbol=BTCUSDT&interval=1h&limit=10";
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v1/depth
#
#Limit: Default 500; max 1000 (not required value)
#
#    $endpoint   = "https://api.commex.com/api/v1/depth";
#    $parameters = "symbol=BTCUSDT&limit=10";
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v1/trades
#
#    $endpoint   = "https://api.commex.com/api/v1/trades";
#    $parameters = "symbol=BTCUSDT&limit=10";
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v1/aggTrades
#
#    $endpoint   = "https://api.commex.com/api/v1/aggTrades";
#    $parameters = "symbol=BTCUSDT&limit=10";
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v1/ticker/price
#
#    $endpoint   = "https://api.commex.com/api/v1/ticker/price";
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v1/ticker/price
#
#    $endpoint   = "https://api.commex.com/api/v1/ticker/price";
#    $parameters = "symbol=BTCUSDT";
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v1/account
#
#    $endpoint   = "https://api.commex.com/api/v1/account";
#    $api        = $apikey;
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v1/userTrades
#
#    $endpoint   = "https://api.commex.com/api/v1/userTrades";
#    $parameters = "symbol=BTCUSDT";
#    $api        = $apikey;
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v1/asset/tradeFee
#
#    $endpoint   = "https://api.commex.com/api/v1/asset/tradeFee";
#    $parameters = "symbol=BTCUSDT";
#    $api        = $apikey;
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v1/order
#
#    $endpoint   = "https://api.commex.com/api/v1/order";
#    $parameters = "symbol=BTCUSDT&origClientOrderId=KfHKsmFoTmTXQopvRa3xlP";
#    $api        = $apikey;
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v1/allOrders
#
#    $endpoint   = "https://api.commex.com/api/v1/allOrders";
#    $parameters = "symbol=BTCUSDT";
#    $api        = $apikey;
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v1/openOrders
#
#    $endpoint   = "https://api.commex.com/api/v1/openOrders";
#    $parameters = "symbol=BTCUSDT";
#    $api        = $apikey;
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v1/capital/deposit/address
#
#    $endpoint   = "https://api.commex.com/api/v1/capital/deposit/address";
#    $parameters = "coin=USDT&network=ETH";
#    $api        = $apikey;
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v1/capital/deposit/history
#
#    $endpoint   = "https://api.commex.com/api/v1/capital/deposit/history";
#    $api        = $apikey;
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v1/asset/transfer-history
#
#    $endpoint   = "https://api.commex.com/api/v1/asset/transfer-history";
#    $parameters = "type=MAIN_FUTURE";
#    $api        = $apikey;
#    $method     = "GET";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#GET /api/v1/capital/withdraw/history
#
#    $endpoint   = "https://api.commex.com/api/v1/capital/withdraw/history";
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
#POST /api/v1/order
#
#timeInForce: #GTC - Good Till Cancel #OC - Immediate or Cancel #FOK - Fill or Kill #GTX - Good Till Crossing (Post Only)
#
#    $endpoint   = "https://api.commex.com/api/v1/order";
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
#DELETE /api/v1/order
#
#    $endpoint   = "https://api.commex.com/api/v1/order";
#    $parameters = "symbol=BTCUSDT&origClientOrderId=ukhWc5STnRTEYzy8lqpFk0";
#    $api        = $apikey;
#    $method     = "DELETE";
#    ($result, $ping) = rest_api($endpoint, $parameters, $api, $method, $loglevel-1);
#    print Dumper $result;
#
#DELETE /api/v1/openOrders
#
#    $endpoint   = "https://api.commex.com/api/v1/openOrders";
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
