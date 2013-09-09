use Test::More tests => 6;
use strict;
use warnings;
use lib './lib';
use JSON;
use MIME::Base64;

# the order is important
use Apps;
use Dancer::Test;


# Spellcheck

my $res;
my $res_hash;

$res = dancer_response GET => '/spellcheck/service';
$res_hash = decode_json($res->{content});

# no params
is_deeply $res_hash,
    {
       "suggestions" => undef,
       "misspelled_total" => undef,
       "error" => "word' and num_suggest parameters missing"
    },
    "got expected response structure for GET /spellcheck/service";


$res = dancer_response GET => '/spellcheck/service/?word=helo vorld&num_suggest=2';
$res_hash = decode_json($res->{content});

# happy path
is_deeply $res_hash,
    {
       "misspelled_total" => 2,
       "error" => undef,
       "suggestions" => [
          {
             "word" => "helo",
             "suggestions" => [
                "hello",
                "he lo"
             ]
          },
          {
             "suggestions" => [
                "world",
                "voled"
             ],
             "word" => "vorld"
          }
       ]
    },    
    "got expected response structure for GET /spellcheck/service";


# ImgResize

$res = dancer_response GET => '/imgresize/service';
$res_hash = decode_json($res->{content});

# no params
is_deeply $res_hash,
    {
        "error" => "please specify url, x and y parameters"
    },
    "got expected response structure for GET /imgresize/service";

# A pretty crummy happy path text. Should find a way to refer to a local file. 
$res = dancer_response GET => '/imgresize/service?url=http://upload.wikimedia.org/wikipedia/en/8/8a/Forgedspoons-1-.jpg&x=10&y=10';

$res =  encode_base64($res->{content});

chomp $res;
is $res,
'/9j/4AAQSkZJRgABAQEAYABgAAD//gAbQ3JlYXRlZCBieSBBY2N1U29mdCBDb3JwLv/bAEMAAwIC
AgICAwICAgMDAwMEBgQEBAQECAYGBQYJCAoKCQgJCQoMDwwKCw4LCQkNEQ0ODxAQERAKDBITEhAT
DxAQEP/AAAsIAAoACgEBEQD/xAAXAAADAQAAAAAAAAAAAAAAAAAEBgcI/8QAIhAAAgICAgICAwAA
AAAAAAAAAQIDBAURAAYHIRIVFjFB/9oACAEBAAA/AMm4Hx5lsl4nl7L+OpPQrpQQ343QmubNyeNA
wB+W2ZUUggkLr9bHJX2XGjrPY8r1u/NFJZxN2ejM8R2jSRSFGKk6OtqdbA4Zic3mq2H+ur5e7FVk
MbvAlh1jZkYspKg6JDewf4ffFrISyXL9m3bkaeeeZ5JZZD8nd2YksxPskkkknn//2Q==',
    "got expected response structure for GET image url with x, y params";

# invalid image source
$res = dancer_response GET => '/imgresize/service/?url=http://google.com&x=10&y=10';
$res_hash = decode_json($res->{content});

is_deeply $res_hash,
{
    "error" => "Please make sure the URL parameter is pointing to an image."
},
    "got expected response for an invalid image source";


# oversized file
$res = dancer_response GET => '/imgresize/service/?url=http://norvig.com/big.txt&x=10&y=10';
$res_hash = decode_json($res->{content});

is_deeply $res_hash,
{
    "error" => "Image is too large. This service only accepts images under 5MB."
},
    "got expected response for an over size limit file";


