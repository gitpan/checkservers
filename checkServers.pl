#!/usr/bin/perl
#
# checkServers.pl
#
# Checks the status of other servers
#
# $Header: /etc/trinet/admin/RCS/checkServers.pl,v 1.3 2006/08/28 21:04:57 root Exp root $
#
# $Log: checkServers.pl,v $
# Revision 1.3  2006/08/28 21:04:57  root
# Added POD documentation
#
# Revision 1.2  2006/08/28 18:20:28  root
# First mod
#
#

=head1 NAME

checkServers.pl - check the status of (possibly external) servers

=head1 SYNOPSIS

   (command line tool)
   perl checkServers.pl {--debug} {--timeout=xxx}

The optional "debug" switch enables (rather verbose) progress 
messages.

The optional "timeout" switch allows you to specify the timeout
value for retrieving web pages. The default value is 120 seconds
(2 minutes).

=head1 DESCRIPTION

This command-line script makes web connections to a list of URLs
which may reside on the server running this script, or on external
servers. The script will retrieve the HTTP status code and if it 
receives a value other than 200, will e-mail an error message to a
preselected list of addresses.

=head1 CONFIGURATION
Before running this script, edit the file checkServers.pl. The values
that need to be edited are:

=item *

$mail{Smtp} = 'mail.server';
Set this line to the name or IP address of your outgoing (SMTP)
mail server

=item *

%urls
Set this hash to the URLs to be tested

=item *

@emails
Set this array to the list of e-mail addresses to be notified when
a URL scan produces a failed result

=head PREREQUISITES

On Linux/Unix systems this can be easily accomplished with the following
command lines:
   cpan install LWP
   cpan install Mail::Sendmail
   cpan install Getopt::Long

On Windows systems, running ActiveState Perl (http://www.activestate.com),
you can easily install these modules by running the "ppm" program, and
issuing the following commands:
   install Mail::Sendmail
   install Getopt::Long 1


=head1 AUTHOR

Written by Daniel Mahoney <dan@trinetcom.com>

=head1 COPYRIGHT

Copyright (c) 2006 by Trinet Internet Solutions. All rights reserved.

=cut

use LWP::UserAgent;
use Mail::Sendmail;
use Getopt::Long;

my %mail = {};

my $debug = 0;
my $timeout = 120;

GetOptions('debug' => \$debug, 'timeout=s' => \$timeout);

if ($debug) { print "Timeout is $timeout\n"; }

# CONFIGURATION: Set the mail server address in the next line
$mail{Smtp} = 'mail.trinetcom.com';

$mail{From} = 'Test Script <test@trinetcom.com>';
$mail{Subject} = 'System alarm';

# CONFIGURATION: Set the list of URLs to be tested in the next lines
%urls = (
	  "www4" => "http://www.focusfamilymedia.org",
	  "www2" => "http://www.tbn.org"
	);

# CONFIGURATION: Set the list of e-mail addresses to be notified of
# failed access attempts
# NOTE: You must precede the @ sign in your address with a
# backslash.
@emails = ( 
	"dan\@trinetcom.com", 
	"dan\@catfolks.net",  
	"8774339901\@skytel.net");

my $code;
foreach $url_key (keys %urls) {
	$url = $urls{$url_key};
	if ($debug) { print "Checking $url\n"; }
	$code = getCode($url);
	if ($debug) { print "Code = $code\n"; }
	if ($code != 200) {
		if ($debug) { print "Going to report...\n"; }
		foreach $who (@emails, @pages) {
			if ($debug) { print "About to send to $who\n"; }
			$mail{To} = $who;
			$mail{Message} = "Code $code on $url";
			sendmail %mail;
			if ($debug) {
				print "To: $mail{To}, code = ";
				print $Mail::Sendmail::error . "\n";
				print "Log = ";
				print $Mail::Sendmail::log . "\n";
				}
			}
		}
	}
	

sub getCode() {
	$url = @_[0];
	my $ua = LWP::UserAgent->new;
	$ua->agent("checkServers.pl");
	$ua->timeout(60);
	my $req = HTTP::Request->new(GET => $url);
	my $res = $ua->request($req);
	return $res->code;
}
