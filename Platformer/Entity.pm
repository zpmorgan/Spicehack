package Platformer::Entity;
use Modern::Perl;
use Moose;

has platformer => (is => 'ro', isa => 'Platformer');
has name => (is => 'ro', isa => 'Str');
has 'x' => (is => 'rw', isa => 'Num');
has 'y' => (is => 'rw', isa => 'Num');
has size => (is => 'ro', isa => 'Int'); #1 or 2..
#has collisions => (is => 'rw', isa =>'ArrayRef');

has num => (is => 'ro', isa => 'Int',
      lazy => 1,
      default => sub { $_[0]->platformer->load_texture($_[0]->name) }
);

sub do{
   my $self = shift;
}
sub h{return $_[0]->size}
sub w{return $_[0]->size}


#behavior state changes: start/stop moving in r/l directions,etc
#maybe force should be a class! gravity is always exerted down, 
#  normal force is directed from walls, action (left/right) pushes constantly,
#  whereas jumping is instantaneous
has 'forces' => (is=>'ro', isa=>'HashRef',default=>sub{{}});

sub moving{
   my ($self,$dir) = @_;
   $self->forces->{dir}=1;
}
sub stop_moving{
   my ($self,$dir) = @_;
   $self->forces->{dir}=0;
}

1
