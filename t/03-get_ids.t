#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 12;
use lib 't/lib';
require 'spotify_lookup.pl';

sub test_get_ids {
	my $uri = shift;
	my @types = qw(artist album track);

	for (@types) {
		is_deeply(
			[get_ids("spotify:$_:$uri")],
			["spotify:$_:$uri"],
			"spotify:$_:$uri"
		);

		is_deeply(
			[get_ids(join(' ', ("spotify:$_:$uri")x2))],
			[("spotify:$_:$uri")x2],
			join(' ', ("spotify:$_:$uri")x2)
		);


		is_deeply(
			[get_ids("This $_ is nice: spotify:$_:$uri, have ".
			         "you heard him/her/it?")],
			["spotify:$_:$uri"],
			"This $_ is nice: spotify:$_:$uri, have you heard him/her/it?"
		);
	}
}

test_get_ids('6G9fHYDCoyEErUkHrFYfs4');

is_deeply(
	[get_ids(
		'spotify:track:6G9fHYDCoyEErUkHrFYfs4 ' .
		'spotify:album:6G9fHYDCoyEErUkHrFYfs4 ' .
		'spotify:artist:6G9fHYDCoyEErUkHrFYfs4'
	)],
	[
		'spotify:track:6G9fHYDCoyEErUkHrFYfs4',
		'spotify:album:6G9fHYDCoyEErUkHrFYfs4',
		'spotify:artist:6G9fHYDCoyEErUkHrFYfs4'
	],
	'spotify:track:6G9fHYDCoyEErUkHrFYfs4 '.
	'spotify:album:6G9fHYDCoyEErUkHrFYfs4 '.
	'spotify:artist:6G9fHYDCoyEErUkHrFYfs4'
);

is_deeply(
	[get_ids('spotify:user:zibri:playlist:6G9fHYDCoyEErUkHrFYfs4')],
	[],
	'spotify:user:zibri:playlist:6G9fHYDCoyEErUkHrFYfs4'
);

is_deeply(
	[get_ids('This playlist is good spotify:user:zibri:playlist:6G9fHYDCoyEErUkHrFYfs4')],
	[],
	'This playlist is good spotify:user:zibri:playlist:6G9fHYDCoyEErUkHrFYfs4',
);

