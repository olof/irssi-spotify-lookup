#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use JSON;
use File::Basename;
use lib 't/lib';
require 'spotify_lookup.pl';

sub load_ref {
	my $uri = shift;
	open my $fh, '<', "t/data/$uri.json" or
		die("Could not open ref data for $uri: $!\n");
	my $json = do { local $/=''; <$fh> };
	close $fh;

	return decode_json($json);
}

sub verify_json {
	my $uri = shift;
	my $ref = load_ref($uri);

	is_deeply(
		spotify_lookup($uri),
		$ref,
		$uri
	);

}

my @ref_files = glob('t/data/*');
plan tests => 1 + @ref_files;

for my $ref_fname (@ref_files) {
	my $uri = basename $ref_fname;
	$uri =~ s/\.json$//;
	verify_json($uri);
}

is_deeply(
	spotify_lookup('spotify:artist:void'),
	{error=>'Not found'},
	'spotify:artist:void (does not exist)'
);

