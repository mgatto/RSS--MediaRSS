package RSS::MediaRSS;
# ABSTRACT: Creates a Media RSS file by recursively scanning for Media files from a root directory.

use Modern::Perl;
use Moo;
use Lingua::EN::Titlecase::Simple qw(titlecase);
use File::Next;
use File::Basename;
use XML::RSS;
use URI;
use Data::Dumper;
use Image::ExifTool qw(:Public);
use Params::Validate qw(:all);
use Exception::Class(
    'Example::Module::X::Args' => { alias => 'throw_args', },
);
Params::Validate::validation_options(
    on_fail => sub { throw_args(error => shift) },
);

has player_url => (
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

has rss_writer => (
    is => 'ro',
    default => sub {
        return XML::RSS->new(version => '2.0');
    }
);

=head2 BUILD

=cut
sub BUILD {

}

=head2 as_string
    $rss = RSS::MediaRSS::Video->new({
        player_url  => 'http://www.example.com/videos/player.swf',
        title       => '',
        link        => '',
        description => '',
    });
    $mrss = $rss->as_string('/srv/www/example.com/public/videos', 'http://www.example.com/video');
    $rss->as_file('/srv/www/example.com/public/videos/myvideos.rss');
=cut
sub as_string {
    my $self = shift;
    my %params = validate(
        @_, {
            video_root =>
                # specify a type
                { type => SCALAR },
            base_url =>
                # specify a type
                { type => SCALAR },
            filter => {
                type      => ARRAYREF,     # [mp4 webm mpeg] etc...
                optional => 1,
            },
        }
    );

    $self->start_feed;

    # need to use everything() instead of file()
    my $files = File::Next::files( { file_filter => sub { /\.webm$/ } }, $params{'video_root'} );
    while ( defined ( my $file = $files->() ) ) {
       $self->add_media_item_to_feed({
           path => $file,
           link => $params{'base_url'}
       });
    }

    # return the rss as a string
    return $self->rss_writer->as_string;
};

=head2 as_file

=cut
sub as_file {
    #get the Object first
    my $self = shift;

    # make sure its valid-ish...
    my %params = validate_pos(@_, { type => SCALAR });

    my $full_file_path = shift;
    $self->rss_writer->save($full_file_path);
};

=head2 start_feed

=cut
sub start_feed {
    my $self = shift;

    $self->rss_writer->add_module(prefix=>'media', uri=>'http://search.yahoo.com/mrss/');
    $self->rss_writer->channel(
        title       => $self->description,
        link        => $self->link,
        description => $self->description,
    );
};

=head2 add_media_item_to_feed
    $_ is the name of the current file being processed

    $File::Find::name is the full path

=cut

sub add_media_item_to_feed {
    my $self = shift;

    my %params = validate(
        @_, {
            path =>
                # specify a type
                { type => SCALAR },
            link =>
                # specify a type
                { type => SCALAR },
        }
    );

    my $info = ImageInfo($params{'path'});

    #is there a plain Englis title in the embedded metadata?
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
                url         => $self->link . '/' . basename($params{'path'}),
                duration    => "$$info{'Duration'}", # = mp4
                size        => "$$info{'FileSize'}", # = mp4
                #need to get the stream to get the language...
                lang        => "en",
            },
            title        => ucfirst($title),
            #can we look for a text file? or extract from file metadata?
            description  => "", # comments tag; Description = mp4
            player       => {
                url => $self->player_url . "?file="  . $uri->path . basename($params{'path'})
            }#,
            #thumbnail    => {
            #    url => "http://jamesacook.net/assets/images/"
            #}
        }
    );
};

# sub make_thumbnail {};

1; # End of RSS::MediaRSS::Video

=head1 AUTHOR

Michael Gatto, C<< <mgatto at lisantra.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-xml--rss--mrss--video at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=XML--RSS--MRSS--Video>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc RSS::MediaRSS


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=XML--RSS--MRSS--Video>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/XML--RSS--MRSS--Video>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/XML--RSS--MRSS--Video>

=item * Search CPAN

L<http://search.cpan.org/dist/XML--RSS--MRSS--Video/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 SYNOPSIS

Perhaps a little code snippet.

    use RSS::MediaRSS;

    my $foo = RSS::MediaRSS->new();
    ...

=head1 EXPORT

as_string as_file

=method method_x

This method does something experimental.

=method method_y

This method returns a reason.

=head1 SEE ALSO

=for :list
* L<Your::Module>
* L<Your::Package>
