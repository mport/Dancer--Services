use Test::More tests => 10;
use strict;
use warnings;
use lib './lib';

# the order is important
use Apps;
use Dancer::Test;

route_exists [GET => '/'], 'a route handler is defined for /';
response_status_is ['GET' => '/'], 200, 'response status is 200 for /';

route_exists [GET => '/spellcheck'], 'a route handler is defined for /spellcheck';
response_status_is ['GET' => '/spellcheck'], 200, 'response status is 200 for /spellcheck';


route_exists [GET => '/imgresize'], 'a route handler is defined for /imgresize';
response_status_is ['GET' => '/imgresize'], 200, 'response status is 200 for /imgresize';

route_exists [GET => '/spellcheck/service'], 'a route handler is defined for /spellcheck/service';
response_status_is ['GET' => '/spellcheck/service'], 200, 'response status is 200 for /spellcheck/service';

route_exists [GET => '/imgresize/service'], 'a route handler is defined for /imgresize/service';
response_status_is ['GET' => '/imgresize'], 200, 'response status is 200 for /imgresize/service';
