#!/usr/bin/perl
# Copyright 2013, Olof Johansson <olof@ethup.se>
#
#   Based on youtube_title.pl:
#    Copyright 2009--2011, Olof Johansson <olof@ethup.se>
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

use strict;
use Irssi;
use LWP::UserAgent;
use JSON;

my $VERSION = '0.1';

my %IRSSI = (
	authors     => 'Olof "zibri" Johansson',
	contact     => 'olof@ethup.se',
	name        => 'spotify-lookup',
	uri         => 'https://github.com/olof/irssi-spotify-lookup',
	description => 'prints info on a spotify URI when mentioned',
	license     => 'GNU APL',
);

sub callback {
	my ($server, $msg, $nick, $address, $target) = @_;
	$target = $nick unless defined $target;

	# process each spotify identifier in message
	process($server, $target, $_) for get_ids($msg);
}

sub process {
	my ($server, $target, $id) = @_;
	my $data = spotify_lookup($id);

	if (not exists $data->{info}->{type}) {
		print_error(
			$server, $target,
			$data->{error} // "Could not lookup $id"
		);
		return;
	}

	print_spotify($server, $target, $data->{info}->{type}, $data);
}

sub get_ids {
	my $msg = shift;
	return $msg =~ /\b(spotify:(?:artist|album|track):\w+)\b/gi;
}

# Reference: https://developer.spotify.com/technologies/web-api/lookup/
sub spotify_lookup {
	my($id)=@_;
	my $url = "http://ws.spotify.com/lookup/1/.json?uri=$id";

	my $ua = LWP::UserAgent->new();
	$ua->agent("$IRSSI{name}/$VERSION (irssi)");
	$ua->timeout(3);
	$ua->env_proxy;

	my $response = $ua->get($url);

	return {error => $response->message} unless $response->code == 200;
	my $json = $response->decoded_content;
	return decode_json($json);
}

my %type_keys = (
	artist => sub {
		my $d = shift;
		(
			$d->{artist}->{name}
		)
	},
	album => sub {
		my $d = shift;
		(
			$d->{album}->{artist},
			$d->{album}->{name},
			$d->{album}->{released}
		)
	},
	track => sub {
		my $d = shift;
		(
			$d->{track}->{artists}->[0]->{name},
			$d->{track}->{name},
			$d->{track}->{album}->{name},
			sprintf '%.2f', $d->{track}->{length} / 60,
		)
	}
);

sub print_error {
	my ($server, $target, $msg) = @_;
	$server->window_item_find($target)->printformat(
		MSGLEVEL_CLIENTCRAP, 'spotify_error', $msg
	);
}

sub print_spotify {
	my ($server, $target, $type, $d) = @_;

	if (not $type_keys{$type}) {
		print_error($server, $target, "Unknown type '$type'");
		return;
	}

	$server->window_item_find($target)->printformat(
		MSGLEVEL_CLIENTCRAP, "spotify_$type", $type_keys{$type}->($d)
	);
}

Irssi::theme_register([
	'spotify_artist', '%yspotify:%n $0',
	'spotify_album', '%yspotify:%n $0 - $1 ($2)',
	'spotify_track', '%yspotify:%n $0 - $1 (on $2) [$3 min]',
	'spotify_error', '%rError looking up spotify:%n $0',
]);

Irssi::signal_add("message public", \&callback);
Irssi::signal_add("message private", \&callback);

1;
