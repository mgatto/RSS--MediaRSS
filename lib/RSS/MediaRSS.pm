package RSS::MediaRSS;
# ABSTRACT: Creates a Media RSS file by recursively scanning for Media files from a root directory.

use Modern::Perl;
use Moo;
use RSS::MediaRSS::Writer;
use RSS::MediaRSS::Exceptions;
use Params::Validate qw(:all);

use Data::Dumper;

#Params::Validate::validation_options(
#    on_fail => sub { throw_validation(error => shift) },
#);

# Moo class member definitions
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

=attr filter

=cut
has filter => (
    is => 'rw',
);

=attr player_url

=cut
has player_url => (
    is => 'ro',
);

=attr title

=cut
has title => (
    is => 'ro',
);
=attr link

=cut
has link => (
    is => 'ro',
);
=attr description

=cut
has description => (
    is => 'ro',
);

=method BUILD

    Pass vital configuration parameters to RSS::MediaRSS

    $rss = RSS::MediaRSS::Video->new({
        media_filesystem_root => '',
        media_base_url        => '',
        player_url            => 'http://www.example.com/videos/player.swf',
        title                 => '',
        link                  => '',
        description           => '',
    });

    'media_filesystem_root' and 'media_base_url' are absolutely required.
    player_url is becoming optional, especially in the age of ever-maturing HTML5
    Video support, which makes flash-based players, and their urls, increasingly
    superfluous.
=cut
sub BUILD {
    my $self = shift;

    my %params = validate(
        @_, {
            media_filesystem_root =>
                # specify a type
                { type => SCALAR },
            media_base_url =>
                # specify a type
                { type => SCALAR },
            filter => {
                type      => ARRAYREF,     # [mp4 webm mpeg] etc...
                optional => 1,
            },
            player_url => {
                type      => SCALAR,     # http://www.example.org/player.swf
                optional => 1,
            },
            title => {
                type      => SCALAR,     # http://www.example.org/player.swf
                optional => 1,
            },
            link => {
                type      => SCALAR,     # http://www.example.org/player.swf
                optional => 1,
            },
            description => {
                type      => SCALAR,     # http://www.example.org/player.swf
                optional => 1,
            },
        }
    );
}

=method as_string

    Return the generated MediaRSS as a string

    $mrss = $rss->as_string();

    Or, with an optional filter:

    $mrss = $rss->as_string({
        filter => ['mp4', 'mpeg']
    });

    Allow this syntax, too? $mrss = $rss->as_string(['mp4', 'mpeg']);
=cut
sub as_string {
    my $self = shift;

    my %params = validate(
        @_, {
            filter => {
                type      => ARRAYREF,     # [mp4 webm mpeg] etc...
                optional => 1,
            },
        }
    );

    # Instantiate the writer, telling it where to look
    #@TODO is it a Writer or a Finder?
    my $writer = RSS::MediaRSS::Writer->new({
        media_filesystem_root => $self->media_filesystem_root,
        filter                => $params{'filter'} || $self->filter,
    });

    $writer->start_feed({
        title       => $self->title,
        link        => $self->link,
        description => $self->description,
    });

    $writer->add_entries({
        media_base_url => $self->media_base_url,
        player_url  => $self->player_url,
        filter => $params{'filter'} || $self->filter,
    });

    # get back the MediaRSS as a string
    # Kind of wierd having a wrapper for XML::RSS::as_string also called
    # "as_string", isn't it?
    return $writer->rss_writer->as_string;
};

=method as_file

    Write the generated MediaRSS to a file

    $mrss->as_file('/srv/www/example.com/public/videos/myvideos.rss');

    Or, with an optional file format filter:

    $mrss->as_file('/srv/www/example.com/public/videos/myvideos.rss', ['m4v', 'mp4']);
=cut
sub as_file {
    #get the Object first
    my $self = shift;

    # make sure its valid-ish...
    my %params = validate_pos(@_, { type => SCALAR });
    #my %params = validate(
    #    @_, {
    #        filter => {
    #            type      => ARRAYREF,     # [mp4 webm mpeg] etc...
    #            optional => 1,
    #        },
    #    }
    #);

    my $writer = RSS::MediaRSS::Writer->new({
        media_filesystem_root => $self->media_filesystem_root,
        filter                => $params{'filter'} || $self->filter,
    });

    $writer->start_feed({
        player_url  => $self->player_url,
        title       => $self->title,
        link        => $self->link,
        description => $self->description,
    });

    $writer->add_entries({
        filter => $params{'filter'} || $self->filter,
    });

    return $writer->save($params{0});
};

1; # End of RSS::MediaRSS::Video
