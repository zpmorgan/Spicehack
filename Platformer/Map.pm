package Platformer::Map;
use Platformer::Map::Blob;
use Modern::Perl;
use Moose;


# Map should be arranged as a directed graph with levels, of a sort.
# composed of blobs of varying shapes and sizes.
# blobs can link to other blobs to all 5 sides (doors + 4 directions).
# blobs aren't generated until player goes there.
# blob is frozen when player is sufficiently far
# unfrozen blobs & their entities are to be handled as a combined unit.
#blobs are to be connected with blobconnections

has viewport => (is => 'rw', isa => 'Platformer::Viewport');
has platformer => (is => 'ro', isa => 'Platformer');
#has default_tile => (is => 'ro', isa => 'Tile');

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
   default => sub {$_[0]->entry_blob}
);

sub entry_blob{
   my $self = shift;
   my $blob_constraints = {
      space => [ 
         (map {[$_,4]} (4..11)),
         (map {[11,$_]} (4..11)),
      ],
      solid => [
         (map {[$_,5]} (5..10)),
         (map {[$_,$_]} (3..8)),
      ],
      connection => 'right',
   };
   my $blob = Platformer::Map::Blob->new(
      x=>0,'y'=>0, sign=>0,map=>$self,
      gen_constraints => $blob_constraints
   );
   return $blob;
}

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
sub visible_entities{
   my $self = shift;
   my @ents = @{$self->main_blob->entities};
}

1;
