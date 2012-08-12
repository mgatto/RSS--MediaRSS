package XML::RSS::Media::Video;

use Modern::Perl;
use Moo;
use Lingua::EN::Titlecase::Simple qw(titlecase);
use File::Next;
use File::Basename;
use MP4::Info;
use XML::RSS;
use URI;
use Data::Dumper;
use Params::Validate qw(:all);

=head1 NAME

XML::RSS::Media::Video - Creates a Media RSS file by recursing from a root directory.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

our @EXPORT = qw(as_string as_file);

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use XML::RSS::Media::Video;

    my $foo = XML::RSS::Media::Video->new();
    ...

=head1 EXPORT

as_string as_file

=head1 SUBROUTINES/METHODS

This will not work well if the file names are one long string without hyphens or underscores.


=cut

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
        return XML::RSS->new (version => '2.0');
    }
);

=head2 BUILD

=cut
sub BUILD {

}

=head2 as_string
    $rss = XML::RSS::Media::Video->new({
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
    my $files = File::Next::files( { file_filter => sub { /\.mp4$/ } }, $params{'video_root'} );
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

    my $info = get_mp4info($params{'path'});
    my $title = basename($params{'path'});

    #strip the extension and punctuation
    $title =~ s/\.[^.]+$//;
    $title =~ s/[^\w\d]/ /g;
print Dumper($title);
    # title case it
    #$title =~ s/-(\w)/ \u\L$1/g;
print Dumper($title);
    #my $titlecaser = Lingua::EN::Titlecase->new();
    #$titlecaser->mixed_threshold('0.50');
print Dumper(titlecase($title));die;
    my $uri = URI->new($params{'link'});

    $self->rss_writer->add_item(
        title => ucfirst($title),
        link => $params{'link'} . basename($params{'path'}),
        media => {
            content      => {
                url         => $self->link . '/' . basename($params{'path'}),
                duration    => "$info->{SECS}",
                size        => "$info->{SIZE}",
                #need to get the stream to get the language...
                lang        => "en",
            },
            title        => ucfirst($title),
            #can we look for a text file? or extract from file metadata?
            description  => "", # comments tag
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

=head1 AUTHOR

Michael Gatto, C<< <mgatto at lisantra.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-xml--rss--mrss--video at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=XML--RSS--MRSS--Video>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc XML::RSS::Media::Video


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


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Michael Gatto.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of XML::RSS::Media::Video
