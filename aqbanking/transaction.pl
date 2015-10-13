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

my (%date, %data);
my ($start, $cnt) = (0, 0);

open (FH, "<$ARGV[0]") or die $!;
while (<FH>) {
  if (/^\s*?transaction\s*?{$/g) {
    $start = 1;
  } elsif (/^\s*?}\s*#transaction$/g) {
    $start = 0;
    $data{$cnt}{date} = "$date{year}-$date{month}-$date{day}T$date{hour}:$date{min}:$date{sec}Z";
    $data{$cnt}{rdate} = $data{$cnt}{date};
    $cnt++;
  } elsif ($start && /^\s*?char\s(\w+?)="(.+?)"$/g) {
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

my $result = "{\"aqbanking\": [";
foreach my $k (keys %data) {
  my $t = $data{$k};
  my $balance = balance($t->{value});
  $result .= "{\"account\": \"$t->{currency}\", \"label\": \"$t->{remoteName}\", ".
    "\"raw\": \"$t->{purpose}\", \"amount\": \"$balance\", \"rdate\": ".
    "\"$t->{rdate}\", \"date\": \"$t->{date}\", \"type\": 0}, ";
}
print substr($result, 0, -2) . "]}\n";

exit 0;
