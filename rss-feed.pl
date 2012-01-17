#!/usr/bin/perl 

use strict;
use warnings;

use Getopt::Long;

use XML::RSS;
use LWP::Simple;
use HTTP::Date;
use Getopt::Long;
use URI::Escape;
use POSIX qw/strftime/;
use LWP;

#$|++;

sub usage {
  die("usage: rss-bolt.pl -t token [-f feed_url] [-s state_file] [-a account_id]
  -t|--token token - specify the authentication token you want to use
  -f|--feed feed_url - URL to RSS feed you want to bolt from (defaults to Google News)
  -s|--state state_file - path to a file where we keep RSS state (defaults to the domain)
  -a|--account account_id - bolt into a specific account, not the default for the token

  More information on the BO.LT API: https://dev.bo.lt/
  You can get your token from: https://bo.lt/app/settings#api-app-form\n");
}

my ($help, $stamp, $verbose);
my $state = "";
my $feedurl = "http://news.google.com/news?ned=us&topic=h&output=rss";
my $token = "";
my $account = "";

GetOptions(
  "feed|f=s" => \$feedurl,
  "state|s=s" => \$state,
  "token|t=s" => \$token,
  "verbose|v" => \$verbose,
  "account|a=s" => \$account,
  "help|h" => \$help
);

if ($token !~ /.+/) {
  print "ERROR: Need to specify an access token (from https://bo.lt/app/settings#api-app-form)\n";
  usage();
}

if ($help) {
  usage();
}

if ($state !~ /.+/) {
  $state = $feedurl;
  $state =~ s/[^A-Za-z0-9\_\-\.]+//g;
  $state = "/tmp/" . $state;
}

sub bolt {
  my $url = $_[0];
  my $comment = $_[1];
  my $token = $_[2];
  my $verbose = $_[3];
  my $account = $_[4];
  my $path = $url . "_" . strftime('%Y-%m-%d_%H_%M_%S',localtime);
  $path =~ s/https?:\/\///;
  $path =~ s/^[_\/]//;
  $path =~ s/\/\//\//g;
  $path =~ s/\/$//;
  $path =~ s/[^A-Za-z0-9\/\-\.\_]/-/g;

  my $encoded_url = uri_escape($url);
  my $encoded_path = uri_escape($path);
  my $bolt_request = "https://api.bo.lt/bolt/create.plain?async=FALSE&url=" . $encoded_url . "&access_token=" . $token . "&path=" . $encoded_path;
  if ($comment =~ /.+/) {
    my $encoded_comment = uri_escape($comment);
    $bolt_request .= "&comment=" . $encoded_comment;
  }
  if ($account =~ /.+/) {
    $bolt_request .= "&account_id=" . $account;
  }
  my $bolt_user_agent = LWP::UserAgent->new;
  my $bolt_output = $bolt_user_agent->get($bolt_request);
  die "ERROR: call failed to " . $bolt_request . " with " . $bolt_output->status_line unless $bolt_output->is_success;
  if ($verbose) {
    print $bolt_output->content;
  } else {
    my $output = $bolt_output->content;
    $output =~ s/.+?bolt.short_url\s+([^\s]+).+/$1/s;
    print "$output\n";
  }
}

sub getNewLinksFromFeed {
  my $stamp = 0;
  my $feed_url = $_[0];
  my $state_file = $_[1];
  my $token = $_[2];
  my $verbose = $_[3];
  if (-e $state_file) {
    local *FILE;
    open FILE, "<$state_file";
    $stamp = <FILE>;
    close FILE;
  }
  my $xml = get($feed_url);
  return unless defined ($xml);
  my $rss_parser  = new XML::RSS;
  $rss_parser->parse($xml);

  my $channel = $rss_parser->{channel};

  foreach my $item (reverse(@{$rss_parser->{items}})) {
    $item->{'pubDate'} =~ s/[A-Z][A-Z][A-Z]+\+(\d\d):(\d\d)/+$1$2/; # work around some timestamps not being recognized by str2time
    if (str2time($$item{pubDate}) > $stamp) {
      $stamp = str2time($$item{pubDate});
      my $title = $item->{'title'};
      my $comment = $item->{'title'};
      my $url = $item->{'link'};
      if ($url =~ /.+/ and $comment =~ /.+/) {
        bolt($url, $comment, $token, $verbose, $account);
      }
    }
  }
  open FILE, ">$state_file";
  print FILE $stamp;
  close FILE;
}

getNewLinksFromFeed($feedurl, $state, $token, $verbose);
