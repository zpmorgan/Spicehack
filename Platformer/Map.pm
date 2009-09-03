package Platformer::Map;
use Modern::Perl;
use Moose;

has platformer => (is => 'ro', isa => 'Platformer');

has tile => (is => 'ro', isa => 'Platformer::Tile',
   lazy => 1,
   default => sub{Platformer::Tile->new (name=>'grassycrap', platformer=>$_[0]->platformer)}
);

#sub BUILD

sub visible_tiles{
   my $self = shift;
   return map {[@$_,$self->tile]}(
      [1,1],[1,2],[2,2],[3,2],[3,3],[3,4],[3,5]
   )
}

1;
