use strict;
use warnings;
use ExtUtils::MakeMaker;

# Normalize version strings like 6.30_02 to 6.3002,
# so that we can do numerical comparisons on it.
my $eumm_version = $ExtUtils::MakeMaker::VERSION;
$eumm_version =~ s/_//;

WriteMakefile(
    NAME                => 'Apps',
    AUTHOR              => q{YOUR NAME <mport@cpan.org>},
    VERSION_FROM        => 'lib/Apps.pm',
    ABSTRACT            => 'YOUR APPLICATION ABSTRACT',
    ($eumm_version >= 6.3001
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'    => 0,
        'YAML'          => 0,
        'Dancer'        => 1.3117,
        'JSON'          => 0,
        'MIME::Base64'  => 0,
        'Dancer::Plugin::Ajax'  => 0,
        'Dancer::Plugin::REST'  => 0,
        'Dancer::Exception'     => 0,
        'Scalar::Util'          => 0,
        'Scalar::Util::Numeric' => 0,
        'List::MoreUtils'       => 0,
        'Image::Magick'         => 0,
        'MIME::Base64'          => 0,
        'WWW::Mechanize'        => 0,
        'Search::Tools::SpellCheck' => 0,

    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Apps-*' },
);
