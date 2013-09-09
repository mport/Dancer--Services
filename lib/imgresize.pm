package apps::imgresize;

use 5.14.0;

use Dancer ':syntax';
use Dancer::Plugin::Ajax;
use Dancer::Plugin::REST;
use Dancer::Exception qw(:all);
use Scalar::Util qw(looks_like_number);
use Scalar::Util::Numeric qw(isint);
use List::MoreUtils qw(all);
use Image::Magick;
use MIME::Base64;
use WWW::Mechanize;

# Register spellchecker exception 
register_exception('ImgResize',
                    message_pattern => "%s"
                  );

set serializer => 'Mutable';

prefix '/imgresize' => sub {

    get '/' => sub {
        template 'imgresize';	
    };
    
    ajax '/' => sub {
        
            my $result = _resize( param('url'), param('x'), param('y') );
            return $result->{error} ? 
                                { error => $result->{error} } : 
                                { image => encode_base64($result->{image}->ImageToBlob()), mime => $result->{image}->Get('mime') };
    };

    prefix '/service' => sub {
        any '/' => sub {
            my $result = _resize( param('url'), param('x'), param('y') );

            my $filename;
            unless ( $result->{error} ) {
            
                # Name file based on last part of url + new dimensions            
                ( $filename  ) = param('url') =~ /([^\/]+$)/;
                $filename = 'resized_' . param('x') . 'x' . param('y') . '_' . $filename;
            }

            
            return $result->{error} ? { error => $result->{error} } : 
                                    send_file ( \$result->{image}->ImageToBlob(), content_type => $result->{image}->Get('mime'), filename => $filename ); 
        };
    };
};


sub _resize {
    my ( $url, $x, $y ) = @_;

    # Put some caps on ImageMagick resources. Can be done in policy.xml of ImageMagick.    
    my $img = Image::Magick->new;
    $img->Set( 'memory-limit' => "200MB" ); # memory limit
    $img->Set( 'map-limit'    => "400MB" ); # memory memory-map limit (if memory limit is exceeded)
    $img->Set( 'disk-limit'   => "500MB" ); # disk limit if memory-map limit is exceeded
    $img->Set( 'area-limit'   => "100MB" ); # pixel-cache image size limit
    $img->Set( 'time-limit'   => 300 );     # time limit in seconds

    # Max response (i.e. image) size in bytes
    my $max_image_size = 5000000; # Limit image size to 5MB
    
    my $mech = WWW::Mechanize->new;
    $mech->max_size($max_image_size); # Apply image size limit 

    my $error;
    my $image;


    try {        
        _validate_imgresize_params( $url, $x, $y );
        $mech->get($url);

        $image = $mech->content;

        unless ( length ( $image ) <= $max_image_size ) {
            raise 'ImgResize' => "Image is too large. This service only accepts images under 5MB.";
        } 

        my $ret_error = $img->BlobToImage($image);

        if ( length( $ret_error ) ) {
            raise 'ImgResize' => "Please make sure the URL parameter is pointing to an image.";
        }

        $img->Set( Gravity => 'Center' );
        $img->Resize( width => $x, height => $y );

    } catch {

        my ($exception) = @_;

        error $exception; # log the exception
        if ( ref $exception eq 'Dancer::Exception::ImgResize' ) {
            $error = $exception->message;
        } elsif ( $exception =~ 'Error GETing' ) {
            $error = "Please make sure the URL parameter is pointing to an image.";
        } else {
            $error = 'Something went terribly wrong. Please make sure that you are passing valid parameters.';
        }
    };

    return  $error ? { error => $error } : { image => $img };
}

sub _validate_imgresize_params {
    my ($url, $x, $y) = @_;

    unless ( $url && $x && $y ) {
        raise 'ImgResize' => "please specify url, x and y parameters";
    }
    
    unless ( all { looks_like_number $_ } ($x, $y) ) {
       raise 'ImgResize' => "dimension parameters must be numeric";
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

apps::imgresize

=head1 SYNOPSIS

curl 'http://localhost:3000/imgresize/service?url=http://example.com/image.jpg&x=640&y=480 > resized_image.jpg'

=head1 DESCRIPTION

apps::imgresize is a RESTful controller for the Image Resize Application which
also doubles as the Image Resize Service interface. ImageMagick libs are used
to perform the resize transform and most image formats are supported. For 
details please see L<http://imagemagick.org>

=head1 IMAGE RESIZE APPLICATION

Takes an image url, height and width dimensions in pixels and displays the 
resized image.

=head1 IMAGE RESIZE SERVICE

Accepts three parameters:

=over 1

=item B<url>

Valid image URL

=item B<x>

Desired new image width in pixels

=item B<y>

Desired new image height in pixels

=back

Requests can be either GET or POST.

=head2 RESPONSE

A successful response is a binary image stream. In a browser, the user is
prompted with a dialog to save/open the image.

On error, the response is a JSON: B<{ error =E<gt> $error }>

=head1 AUTHOR
 
Copyright 2012, Michael Portnoy E<lt>mport@cpan.orgE<gt>. All rights reserved.
 
This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
 
=cut

