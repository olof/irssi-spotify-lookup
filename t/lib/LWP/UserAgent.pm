package LWP::UserAgent;
use warnings;
use strict;
use HTTP::Response;

sub new {
	my $class = shift;
	bless {@_}, $class;
}

sub get {
	my $self = shift;
	my $api_uri = shift;

	my ($uri) = $api_uri =~ /uri=([^&]+)/;

	if (! -e "t/data/$uri.json") {
		return HTTP::Response->new(
			404, 'Not found'
		);
	}

	open my $fh, "t/data/$uri.json" or
		die("Could not open ref data for $uri: $!\n");
	my $json = do { local $/=''; <$fh> };

	return HTTP::Response->new(
		200, 'OK', [
			'Date' => 'Wed, 06 Feb 2013 18:02:37 GMT',
			'Server' => 'lighttpd smisk/1.1.6',
			'Vary' => 'Accept-Charset',
			'Expires' => 'Thu, 07 Feb 2013 18:02:37 GMT',
			'Last-Modified' => 'Tue, 05 Feb 2013 23:29:43 GMT',
			'Content-Type' => 'application/json; charset=utf-8',
			'Content-Length' => length($json),
			'X-Varnish' => 814362769,
			'Age' => 0,
			'Via' => '1.1 varnish',
			'Access-Control-Allow-Origin' => '*',
		], $json
	);
}

sub timeout {
	my $self = shift;
	$self->{timeout} = shift if @_;
	return $self->{timeout};
}

sub agent {
	my $self = shift;
	$self->{agent} = shift if @_;
	return $self->{agent};
}

sub env_proxy {
	my $self = shift;
	$self->{env_proxy} = 1 if @_;
	return $self->{env_proxy};
}

1;
