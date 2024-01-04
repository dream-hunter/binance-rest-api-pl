package BinanceAPI;

use strict;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use JSON;
use Digest::SHA qw(hmac_sha512_hex sha512_hex hmac_sha256_hex sha256_hex);
use REST::Client;
use Time::HiRes qw(gettimeofday);

use Data::Dumper;

$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = ();
@EXPORT_OK   = qw(
    rest_api
);
%EXPORT_TAGS =  ( DEFAULT => [qw(
    &rest_api
)]);

###############################################################################################
#
# Be careful using the code. Careless use of the subs below can result in a loss of money!
#
# Read additional (official) information here: https://binance-docs.github.io/apidocs/spot/en/
#             Binance clone site for russians: https://www.commex.com/api-docs/en/
#
###############################################################################################

sub url_request {
    my $uri        = $_[0];
    my $parameters = $_[1];
    my $api        = $_[2];
    my $method     = $_[3];
    my $loglevel   = $_[4];
    my $response_code = undef;
    my $decoded = undef;
    my $ping = undef;
    my $apikey     = $api->{apikey};
    my $apisecret  = $api->{apisecret};
    my $nonce      = sprintf('%.0f', gettimeofday()*1000);
    my $rest = REST::Client->new();

    if (defined $apikey && defined $apisecret) {
        if (defined $parameters) {
            $parameters .= "&";
        }
        my $preSign = $parameters."timestamp=".$nonce;
        my $signature = hmac_sha256_hex($preSign, $apisecret);
        $uri .= "?".$preSign."&signature=".$signature;
         $rest->addHeader('X-MBX-APIKEY', $apikey);
    } else {
        if (defined $parameters) {
            $uri .= "?$parameters";
        }
    }
    logmessage ("\nurl_request $uri",$loglevel);
    my $ping = gettimeofday();

    if ($method eq "DELETE") {
        $rest->DELETE($uri);
    }
    if ($method eq "GET") {
        $rest->GET($uri);
    }
    if ($method eq "HEAD") {
        $rest->HEAD($uri);
    }
    if ($method eq "POST") {
        $rest->POST($uri);
    }
    $ping = (int((gettimeofday() - $ping)*1000))/1000;
    my $response_body = $rest->responseContent();
    my $response_code = $rest->responseCode();
    if ($response_code == 200 || $response_code == 201) {
        logmessage ("\nurl_request URL response code: $response_code; ",$loglevel-1);
        logmessage ("\nurl_request REST message: \"$response_body\". \n",$loglevel-2);
        my $decoded = eval { decode_json($response_body) };
        if ($@) {
            print "API error. Decode_json failed, invalid json. error:$@\n";
            return (0, undef, $ping);
        }
        return ($response_code, $decoded, $ping);
    } elsif ($response_code == 404) {
        logmessage ("\nurl_request: An error happened. URL response code: $response_code;\n",$loglevel);
        return ($response_code, undef, $ping);
    } else {
        logmessage ("\nurl_request: An unhandeled error happened. URL response code: $response_code;\n$response_body\n",$loglevel);
        return ($response_code, undef, $ping);
    }
}

sub rest_api {
    my $endpoint   = $_[0];
    my $parameters = $_[1];
    my $api        = $_[2];
    my $method     = $_[3];
    my $loglevel   = $_[4];
    my ($response_code, $decoded, $ping) = url_request($endpoint, $parameters, $api, $method, $loglevel-1);
    logmessage ("\nget_api Response code: $response_code",$loglevel);
    if ($response_code == 200 || $response_code == 201) {
        logmessage (" - ok\n",$loglevel);
        return ($decoded, $ping);
    } else {
        logmessage (" - bad\n",$loglevel);
        return (undef, $ping);
    }
}

sub logmessage {
    my $string   = $_[0];
    my $loglevel = $_[1];
    if ($loglevel >= 5 && $loglevel <= 10) { print $string; }
}

1;