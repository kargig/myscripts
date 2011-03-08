#!/usr/bin/perl
# schneierfacts.com random entry parser
# ver: 0.1
# usage: perl schneierfacts.pl
# by kargig [at] void [dot] gr

use warnings;
use HTTP::Request;
use LWP::UserAgent;
use HTML::Entities;

my $url="http://www.schneierfacts.com/";
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

my $quote;
my $size = @CF;
for(my $i = 0; $i < $size; $i++){
    if ($CF[$i] =~ /<p class=\"fact\">/) {
        $CF[$i] =~ s/.*<p class=\"fact\">(.*)/$1/m;
        $CF[$i] =~ s/(.*)<\/p>/$1/m;
        $CF[$i] = decode_entities($CF[$i]);
        $quote = $CF[$i];
        if ($CF[$i+1] =~ /<\/p>/) {
            $CF[$i+1] =~ s/(.*)<\/p>/$1/m;
            $CF[$i+1] = decode_entities($CF[$i+1]);
            $quote = "$CF[$i]" ." $CF[$i+1]";
        }
        $quote =~ s/(.*)\s+/$1/g;
        print "Quote: $quote\n";
        last;
    }
}
