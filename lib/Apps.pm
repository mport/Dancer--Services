package Apps;
use Dancer ':syntax';
use spellcheck;
use imgresize;

our $VERSION = '0.1';

prefix undef;

get '/' => sub {

    template 'index';
};



true;

__END__

