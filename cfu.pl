#!/usr/bin/perl
# commandlinefu.com random entry parser
# ver: 0.1
# usage: perl cfu.pl
# by kargig [at] void [dot] gr
# 
# comments:
# use multiple=1 if you want to display more commands/alternatives out of each page


use warnings;
use HTTP::Request;
use LWP::UserAgent;
use HTML::Entities;

my $multiple=0;     # allow multiple command output 0/1
my $url="http://www.commandlinefu.com/commands/random";
my $ua = LWP::UserAgent->new();
my $doc="";
$ua->agent("Parseheaders");
$ua->max_size('200000');
my $req = HTTP::Request->new( GET => "$url" );
my $result= $ua->request($req);
if ($result->is_success) {
    $doc = $result->content();
}
else { print "FAIL!";}

#load the file to @CF so we can move between $line and $line+1
open my $fh, '<', \$doc or die $!;
my @CF = <$fh>;
close($fh);

my $size = @CF;
my $count=0;
for(my $i = 0; $i < $size; $i++){
        if ($CF[$i] =~ /<div class=\"command\">/ && ($multiple == 1 || $count < 2)) {
            $CF[$i] =~ s/.*<div class=\"command\">(.*)<\/div>/$1/gm;
            $CF[$i] = decode_entities($CF[$i]);
            $count++;
            if ($multiple ==1 || $count < 2) {
                print "CMD: $CF[$i]";
            } else {
                last;
            }
        }
        if ($CF[$i] =~ /<div class=\"description\">/ && ($multiple == 1 || $count < 2)) {
            $CF[$i+1] =~ s/.*<p>(.*)<\/p>/$1/g;
            $CF[$i+1] = decode_entities($CF[$i+1]);
            if ($CF[$i+1] =~ /\w/) {
                print "Description: $CF[$i+1]";
            }
        }
        if ($CF[$i] =~ /<div class=\"summary\">/ && ($multiple == 1 || $count < 2)) {
            $CF[$i+1] =~ s/\s+(.*)<\/div>/$1/gm;
            $CF[$i+1] =~ s/.*<a href=\"(.*)\" title=\".*\">(.*)<\/a>/URL=http:\/\/www.commandlinefu.com$1  Title=$2/g;
            $CF[$i+1] = decode_entities($CF[$i+1]);
            print "Summary: $CF[$i+1]";
        }
}
