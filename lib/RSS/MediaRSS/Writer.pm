package RSS::MediaRSS::Writer;
# ABSTRACT: compile metadata into a mRSS structure

use Modern::Perl;
use Moo;
use File::Next;
use File::Basename;
use XML::RSS;
use URI;
use Lingua::EN::Titlecase::Simple qw(titlecase);
use Params::Validate qw(:all);
use RSS::MediaRSS::Exceptions;
# @TODO split out into the MetadataReaders Package
use Image::ExifTool qw(:Public);

use Data::Dumper;

has rss_writer => (
    is => 'ro',
    default => sub {
        return XML::RSS->new(version => '2.0');
    }
);

has media_rss => (
    is => 'rw',
);

=attr media_filesystem_root

=cut
has media_filesystem_root => (
    is => 'ro',
);

=attr media_base_url

=cut
has media_base_url => (
    is => 'ro',
);

has filter => (
    is => 'rw',
);

has title => (
    is => 'rw',
);

has link => (
    is => 'rw',
);

has description => (
    is => 'rw',
);




=method start_feed

=cut
sub start_feed {
    my( $self, $args_ref ) = @_;
    $self->rss_writer->add_module(prefix=>'media', uri=>'http://search.yahoo.com/mrss/');
    $self->rss_writer->channel(
        title       => $args_ref->{'description'},
        link        => $args_ref->{'link'},
        description => $args_ref->{'description'},
    );
};

=method add_entries

=cut
sub add_entries {
    my( $self, $args_ref ) = @_;

    #@TODO handle filters

    # need to use everything() instead of file()
    my $files = File::Next::files( { file_filter => sub { /\.webm$/ } }, $self->media_filesystem_root );
    while ( defined ( my $file = $files->() ) ) {
        $self->add_media_item_to_feed({
            player_url => $args_ref->{'player_url'},
            path => $file,
            link => $args_ref->{'media_base_url'},
        });
    }
};

#@TODO move to MetadataReader/Normalizer
=head2 add_media_item_to_feed
    $_ is the name of the current file being processed

    $File::Find::name is the full path

=cut
sub add_media_item_to_feed {
    my $self = shift;

    my %params = validate(
        @_, {
            player_url => { type => SCALAR },
            path => { type => SCALAR },
            link => { type => SCALAR },
        }
    );

    my $info = ImageInfo($params{'path'});

    #is there a plain English title in the embedded metadata?
    my $title = basename($params{'path'});
    if ( exists $$info{'Title'}  ) { # Title = mp4
        my  $title = $$info{'Title'};
    }

    # $info{'comments'} = theora

    #strip the extension and punctuation
    $title =~ s/\.[^.]+$//;
    $title =~ s/[^\w\d]/ /g;

    # title case it
    $title = titlecase($title);

    my $uri = URI->new($params{'link'});

    $self->rss_writer->add_item(
        title => ucfirst($title),
        link => $params{'link'} . basename($params{'path'}),
        media => {
            content      => {
                url         => $params{'link'} . '/' . basename($params{'path'}),
                duration    => "$$info{'Duration'}", # = mp4
                size        => "$$info{'FileSize'}", # = mp4
                #need to get the stream to get the language...
                lang        => "en",
            },
            title        => ucfirst($title),
            #can we look for a text file? or extract from file metadata?
            description  => "", # comments tag; Description = mp4
            player       => {
                url => $params{'player_url'} . "?file="  . $uri->path . basename($params{'path'})
            },
            thumbnail    => {
                url => "http://jamesacook.net/assets/images/"
            }
        }
    );
};

=method make_thumbnail

=cut
sub make_thumbnail {};


1;
