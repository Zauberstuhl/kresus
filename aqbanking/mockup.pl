#!/usr/bin/perl
#
use strict;
use Data::Dumper;

# history
# {"paypal": [{"account": "EUR", "label": "eBay - Price-Guard AG", "raw": "eBay - Price-Guard AG", "amount": "-69.9", "rdate": "2015-10-11T00:00:00Z", "date": "2015-10-11T00:00:00Z", "type": 0},

# account
# {"paypal": [{"balance": "0.00", "label": "lukas@zauberstuhl.de EUR*", "accountNumber": "EUR"}]}

my %date = {};
my ($start, $cnt, %data) = (0, 0, {});
open (FH, "<$ARGV[0]") or die $!;
while (<FH>) {
  if (/^\s*?transaction\s*?{$/g) {
    $start = 1;
  } elsif (/^\s*?}\s*#transaction$/g) {
    $start = 0;
    $data{$cnt}{date} = "$date{year}-$date{month}-$date{day}T$date{hour}:$date{min}:$date{sec}Z";
    $data{$cnt}{rdate} = $data{$cnt}{date};
    $cnt++;
  } elsif ($start && /^\s*?char\s(\w+?)="([\w\d\%\-]+?)"$/g) {
    $data{$cnt}{$1} = $2;
  } elsif ($start && /^\s*?int\s*(\w+?)="(\d+?)"$/g) {
    my $num = $2;
    if (length($num) == 1) {
      $num = "0$num";
    }
    $date{$1} = $num;
  }
}
close FH;

print scalar(keys %data) . "\n";
print Dumper \%data;

exit 0;
