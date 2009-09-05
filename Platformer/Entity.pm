package Platformer::Entity;
use Modern::Perl;
use Moose;

has platformer => (is => 'ro', isa => 'Platformer');
has name => (is => 'ro', isa => 'Str');
has 'x' => (is => 'rw', isa => 'Num');
has 'y' => (is => 'rw', isa => 'Num');
has size => (is => 'ro', isa => 'Int');
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

1
