#!/usr/bin/perl
#
use strict;

sub balance {
  my $aqb_num = shift or return 0;
  if ($aqb_num =~ /^([-\d]+?)%2F(\d+?)$/g) {
    return int($1) / int($2);
  }
  return 0;
}

my %data;
my ($start, $balance, $cnt) = (0, 0, 0);

open (FH, "<$ARGV[0]") or die $!;
while (<FH>) {
  if (/^\s*?accountInfo\s*?{$/g) {
    $start = 1;
  } elsif (/^\s*?}\s*#accountInfo$/g) {
    $start = 0;
    $cnt++;
  } elsif (/^\s*?notedBalance\s*?{$/g) {
    $balance = 1;
  } elsif (/^\s*?}\s*#notedBalance$/g) {
    $balance = 0;
  } elsif ($balance && /^\s*?char\svalue="(.+?)"$/g) {
    $data{$cnt}{balance} = $1;
  } elsif ($start && /^\s*?char\s(\w+?)="(.+?)"$/g) {
    $data{$cnt}{$1} = $2;
  }
}
close FH;

my $result = "{\"aqbanking\": [";
foreach my $k (keys %data) {
  my $t = $data{$k};
  $result .= "{\"balance\": \"" . balance($t->{balance}) .
    "\", \"label\": \"$t->{bankName}\", \"accountNumber\": \"$t->{accountNumber}\"}, ";
}
print substr($result, 0, -2) . "]}\n";

exit 0;
