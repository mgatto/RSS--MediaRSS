package XML::RSS::MRSS::Video;

use Modern::Perl;
use Moo;
#use File::Find;
use File::Next;
use File::Basename;
use MP4::Info;
use XML::RSS;
use Data::Dumper;

=head1 NAME

XML::RSS::MRSS::Video - Creates a Media RSS file by recursing from a root directory.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

our @EXPORT = qw(toMediaRSS);

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use XML::RSS::MRSS::Video;

    my $foo = XML::RSS::MRSS::Video->new();
    ...

=head1 EXPORT

toMediaRSS

=head1 SUBROUTINES/METHODS

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

=head2 toMediaRSS
    $rss = XML::RSS::MRSS::Video->new({
        player_url  => 'http://www.example.com/videos/player.swf',
        title       => '',
        link        => '',
        description => '',
    });
    $mrss = $rss->toMediaRSS('/srv/www/example.com/public/videos', 'http://www.example.com/video');
    $rss->as_file('/srv/www/example.com/public/videos/myvideos.rss');
=cut
sub toMediaRSS {
    my $self = shift;

    my $root_video_directory = shift;
    my $base_url = shift;

    $self->start_feed;

    # need to use everything() instead of file()
    my $files = File::Next::files( { file_filter => sub { /\.mp4$/ } }, $root_video_directory );
    while ( defined ( my $file = $files->() ) ) {
       $self->add_media_item_to_feed( $file );
    }

    #my @directories = ($root_video_directory);
    # can replace with File::Find::Object or File::Next
    #find({ wanted => \&add_media_item_to_feed, follow => 1 }, @directories);

    # return the rss as a string
    return $self->rss_writer->as_string;
};

=head2 BUILD

=cut
sub BUILD {

}

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
    my $full_file_path = shift;

    my $info = get_mp4info($full_file_path);

    my $title = basename($full_file_path);
    #
    $title =~ s/-(\w)/ \u\L$1/g;
    $title =~ s/\.[^.]+$//;
    #$title = Lingua::EN::Titlecase->new($title);

    $self->rss_writer->add_item(
        title => ucfirst($title),
        link => $self->link,
        media => {
            content      => {
                url         => $self->link . '/' . basename($full_file_path),
                duration    => "$info->{SECS}",
                size        => "$info->{SIZE}",
                #need to get the stream to get the language...
                lang        => "en",
            },
            title        => ucfirst($title),
            #can we look for a text file? or extract from file metadata?
            description  => "",
            player       => {
                url => $self->player_url . "?file=" . basename($full_file_path)
            }#,
            #thumbnail    => {
            #    url => "http://jamesacook.net/assets/images/"
            #}
        }
    );
};

sub as_file {
    my $self = shift;

    my $full_file_path = shift;
    $self->rss_writer->save($full_file_path);
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

    perldoc XML::RSS::MRSS::Video


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

1; # End of XML::RSS::MRSS::Video
