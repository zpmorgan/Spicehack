package Platformer::Viewport;
use Modern::Perl;
use Moose;

has 'map' => (is => 'ro',isa=>'Platformer::Map');
has 'x' => (is=>'rw',isa=>'Num');
has 'y' => (is=>'rw',isa=>'Num');
has 'tilesize' => (is=>'rw',isa=>'Int', default => 32);
has height => (is => 'ro', isa => 'Int');
has width  => (is => 'ro', isa => 'Int');

#what does this viewport follow?
has tracking => (is => 'ro',isa=>'Platformer::Entity', default => sub{$_[0]->map->platformer->main} );

#for now, track main in the very center of view
sub update{
   my $self = shift;
   $self->x ($self->main->x - ($self->width / (2*$self->tilesize)));
   $self->y ($self->main->y - ($self->height/ (2*$self->tilesize)));
   
}

1
