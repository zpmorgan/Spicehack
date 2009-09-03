package Platformer::Tile;
use Modern::Perl;
use Moose;

has platformer => (is => 'ro', isa => 'Platformer');
has name => (is => 'ro', isa => 'Str');
#filename is assumed $name.png
has num => (is => 'ro', isa => 'Int',
      lazy => 1,
      default => sub { $_[0]->platformer->load_texture($_[0]->name) }
);



1;
