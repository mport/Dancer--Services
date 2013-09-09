package apps::spellcheck;

use 5.14.0;

use Dancer ':syntax';
use Dancer::Plugin::Ajax;
use Dancer::Plugin::REST;
use Search::Tools::SpellCheck;
use Scalar::Util qw(looks_like_number);
use Scalar::Util::Numeric qw(isint);
use Dancer::Exception qw(:all);


# Register spellchecker exception 
register_exception('Spellchecker',
                    message_pattern => "%s",
                  );

set serializer => 'Mutable';

prefix '/spellcheck' => sub {

    get '/' => sub {
        template 'spellcheck';	
    };
    
    ajax '/' => sub {
        return _spellcheck( param('word'), param('num_suggest') ); 
    };

    prefix '/service' => sub {
        any '/' => sub {
            return _spellcheck( param('word'), param('num_suggest') );
        };
    };
};


sub _spellcheck {
    my ( $word, $num_suggest ) = @_;

    
    my $suggestions;
    my $misspelled_total;
    
    my $error;

    try {
        
        _validate_spellcheck_params( $word, $num_suggest);

        my $spellcheck = Search::Tools::SpellCheck->new(
                                max_suggest => $num_suggest,
                            );

        $suggestions = $spellcheck->suggest( $word );
        
        # Count total number of misspelled words
        $misspelled_total = 0 ;
        $misspelled_total += $_->{suggestions} ? 1 : 0 for @{$suggestions};

    } catch {
        my ($exception) = @_;
       
        error $exception; # log the exception

        if ( $exception->does('Spellchecker') ) {
            $error = $exception->message;

        } else {
            $error = 'Something went terribly wrong. Please make sure that you are passing valid parameters.';
        }
    };

    return { suggestions => $suggestions, misspelled_total => $misspelled_total, error => $error };
}

sub _validate_spellcheck_params {
    my ($word, $num_suggest) = @_;


    unless ( $word && $num_suggest ) {
       raise 'Spellchecker' => "word' and num_suggest parameters missing";
    }

    unless ( looks_like_number $num_suggest ) {
       raise 'Spellchecker' => "number of suggestions must be numeric";
    }
    
    unless ( isint($num_suggest) and $num_suggest > 0) {
       raise 'Spellchecker' => "number of suggestions must be a positive integer";
    }
    
    unless ( $word ) {
       raise 'Spellchecker' => "please specify at least one word to spellcheck";
    }
}

# JSONP support
hook 'after' => sub {
    my $response = shift;    
    
    $response->{content} = params->{callback} . '(' . $response->{content} . ')'
        if params->{callback};
};


true;

__END__

=head1 NAME

apps::spellcheck

=head1 SYNOPSIS

=head2 REQUEST

curl 'http://localhost:3000/spellcheck/service?word=helo%20vorld&num_suggest=2'

or

curl -X POST -H 'Content-Type: application/json' -d '{"word":"helo vorld","num_suggest":"2"}' 'http://localhost:3000/spellcheck/service'


=head2 RESPONSE

{
   "suggestions" : [
      {
         "suggestions" : [
            "hello",
            "he lo"
         ],
         "word" : "helo"
      },
      {
         "suggestions" : [
            "world",
            "voled"
         ],
         "word" : "vorld"
      }
   ],
   "error" : null,
   "misspelled_total" : 2
}


=head1 DESCRIPTION

apps::spellcheck is a RESTful controller for the Spellcheck Application which
also doubles as the Spellcheck Service interface.

=head1 SPELLCHECK APPLICATION

Takes several space separated words and the number of suggestions to display 
for each misspelled word. It uses GNU Aspell with a generic English dictionary 
to provide suggestions for the misspelled words.

=head1 SPELLCHECK SERVICE

Accepts two parameters:

=over 1

=item B<word>

One or more space separated words to spellcheck

=item B<num_suggests>

Number of suggestions for each misspelled word

=back

Requests can be either GET or POST.

=head2 RESPONSE

Response format depends on the Content-Type of the request.

Response is structured as follows:

=over 1

=item B<suggestions>

List of suggestions under the key B<suggestions> and the original word
under the key B<word>.

=item B<error>

Any errors if they occur. null otherwise.

=item B<misspelled_total>

Total number of misspelled words

=back

=head1 AUTHOR
 
Copyright 2012, Michael Portnoy E<lt>mport@cpan.orgE<gt>. All rights reserved.
 
This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
 
=cut


