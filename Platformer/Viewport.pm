package Platformer::Viewport;
use Modern::Perl;
use Moose;

has 'map' => (is => 'ro',isa=>'Platformer::Map');
has 'x' => (is=>'rw',isa=>'Num');
has 'y' => (is=>'rw',isa=>'Num');
has 'tilesize' => (is=>'rw',isa=>'Int', default => 32);
has height => (is => 'ro', isa => 'Int', default => 500);
has width  => (is => 'ro', isa => 'Int', default => 700);


