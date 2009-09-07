#!/usr/bin/perl
use Modern::Perl;

use Platformer;

my %params = (
   main => {name => 'mrflash', size=>1},
   monsters => [
      {name=> 'spartan', size=>2},
      {name=> 'gridbug', size=>1},
   ],
);

my $P = Platformer->new (xsize => 600, ysize => 400, params => \%params,);


$P->run;
