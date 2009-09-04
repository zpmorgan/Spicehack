package Platformer::Tile;
use Modern::Perl;
use Moose;


has 'x' => (is => 'rw', isa => 'Num');
has 'y' => (is => 'rw', isa => 'Num');
has 'name' => (is => 'ro', isa => 'Str');
has 'collisions' => (is => 'rw', isa =>'ArrayRef');#?


sub do{
   my $self = shift;
}

1
