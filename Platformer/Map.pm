package Platformer::Map;
use Platformer::Map::Blob;
use Modern::Perl;
use Moose;

has platformer => (is => 'ro', isa => 'Platformer');
has default_tile => (is => 'ro', isa => 'Tile');

#just a generic crappy platform tile
has brick_tile => (
   is => 'ro', isa => 'Platformer::Tile',
   lazy => 1,
   default => sub{Platformer::Tile->new (name=>'grassycrap', platformer=>$_[0]->platformer)}
);

#where player should enter
has main_blob => (
   is => 'ro', isa => 'Platformer::Map::Blob',
   lazy => 1,
   default => sub {Platformer::Map::Blob->new(x=>0,'y'=>0,sign=>0,map=>$_[0])}
);

#sub BUILD

sub invisible_tiles{ #remove
   my $self = shift;
   return map {[@$_,$self->brick_tile]}(
      [1,1],[1,2],[2,2],[3,2],[3,3],[3,4],[3,5]
   )
}

sub visible_tiles{
   my $self = shift;
   my @tiles_co = $self->main_blob->get_tiles;
}

1;
