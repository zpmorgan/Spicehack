#!/usr/bin/perl
use Modern::Perl;

use Platformer;

my $P = Platformer->new (xsize => 600, ysize => 400);

#die $P->map->platformer;

$P->run;
