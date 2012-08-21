#!/usr/bin/perl

use strict;
use warnings;

use File::Find;
use MP4::Info;
use XML::RSS;
#use Lingua::EN::Titlecase;

my $rss = XML::RSS->new (version => '2.0');
$rss->add_module(prefix=>'media', uri=>'http://search.yahoo.com/mrss/');
$rss->channel(
	title          => 'James A Cook: Sculpture Videos',
    link           => 'http://jamesacook.net',
    description    => 'A Tucson, Arizona Sculptor and Video Artist',
);

my @directories = ('C:\Development\Jamesacook.net\Releases\1.2.1\assets\videos');
find(\&wanted, @directories);

sub wanted {	
	my $info = get_mp4info($File::Find::name);	
	
	my $title = $_;
	#
	$title =~ s/-(\w)/ \u\L$1/g;
	$title =~ s/\.[^.]+$//;
	#$title = Lingua::EN::Titlecase->new($title);	
	
	$rss->add_item(
		title => ucfirst($title),
		link => "http://jamesacook.net/",
		media => {
			content      => {
				url		 	=> "http://jamesacook.net/assets/videos/$_",
				duration	=> "$info->{SECS}",
				size		=> "$info->{SIZE}",
				lang 		=> "en",
			},
			title 	   	 => ucfirst($title),
		    description  => "",
		    player       => {
                url => "http://jamesacook.net/assets/flash/player.swf?file=/assets/videos/$_"
            },
			thumbnail	 => {
                url => "http://jamesacook.net/assets/images/"
            }
		}
	);
}


# print the RSS as a string
 ## print $rss->as_string;
 $rss->save("../videos.rss");

exit 0;