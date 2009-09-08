package Platformer::Entity;
use Modern::Perl;
use Moose;

has platformer => (is => 'ro', isa => 'Platformer');
has name => (is => 'ro', isa => 'Str');
has blob => (is => 'rw', isa => 'Platformer::Map::Blob');
has 'x' => (is => 'rw', isa => 'Num'); #x,y only relative to blob!
has 'y' => (is => 'rw', isa => 'Num');
has size => (is => 'ro', isa => 'Int'); #1 or 2..

has num => (is => 'ro', isa => 'Int',
      lazy => 1,
      default => sub { $_[0]->platformer->load_texture($_[0]->name) }
);

sub h{return $_[0]->size}
sub w{return $_[0]->size}


#behavior state changes: start/stop moving in r/l directions,etc
#maybe force should be a class! gravity is always exerted down, 
#  normal force is directed from walls, action (left/right) pushes constantly,
#  whereas jumping is instantaneous
has 'forces' => (is=>'ro', isa=>'HashRef', default=> sub {{lpush=>0,rpush=>0,push=>0}});
has 'hmoment' => (is=>'rw',isa=>'Num',default=>0);
has 'vmoment' => (is=>'rw',isa=>'Num',default=>0);

has 'running' => (is=>'rw',isa=>'Int', trigger=>sub{say$_[1]});

has 'physical_state' => (is=>'rw',isa=>'Str');
has 'mental_state' => (is=>'rw',isa=>'Str');


#hpush and vpush?
sub begin_push{
   my ($self,$dir) = @_;
   $self->forces->{$dir.'push'}=1;
   $self->calc_push();
}
sub stop_push{
   my ($self,$dir) = @_;
   $self->forces->{$dir.'push'}=0;
   $self->calc_push();
}

sub calc_push{
   my $self = shift;
   my $push = $self->forces->{rpush} - $self->forces->{lpush};
   unless ($push){ #no net push.
      $self->forces->{push} = 0;
      return;
   }
   my $mid_x = $self->platformer->viewport->width / 2;
   
   #min push is, say, .05?
   #max push is, say, .3?
   #forcefulness=pixels to one side (in direction of push)
   my $force;
   if ($push==-1){
      my $forcefulness = $self->platformer->mouse_x - $mid_x; # - $self->platformer->viewport->width;
      $force = $forcefulness * .3 / $mid_x;warn $force;
      $force = -.3 if $force < -.3;
      $force = -.05 if $force > -.05;
   }
   elsif ($push==1){
      my $forcefulness = $self->platformer->mouse_x - $mid_x;
      #$forcefulness *= -1 if $push == -1;#left?
      $force = $forcefulness * .3 / $mid_x;
      $force = .3 if $force>.3;
      $force = .05 if $force<.05;
   }
   else {die 'r-l push:' . $push }
   warn $force;
   $self->forces->{push} = $force;
}

sub apply_push{
   my $self = shift;
   my $hmoment = $self->hmoment;
   if (abs($hmoment) > .2){
      return
   }
   $hmoment += $self->forces->{push};
   $self->hmoment($hmoment);
}

sub apply_friction{
   my $self = shift;
   my $hmoment = $self->hmoment;
   return unless $hmoment;
   #todo: return unless on ground..
   if (abs($self->hmoment) < .01){
      $self->hmoment(0);
   }
   elsif ($hmoment>0){
      $self->hmoment ($hmoment-.01)
   }
   else{
      $self->hmoment ($hmoment+.01)
   }
}
my $max_gravity_speed = .5;

sub apply_gravity{
   my $self = shift;
   $self->vmoment($self->vmoment + .03);
   $self->vmoment($max_gravity_speed) if $self->vmoment > $max_gravity_speed;
}
sub jump{
   my $self = shift;
   $self->vmoment(-2);
}

sub on_ground{
   my $self = shift;
   return 1 if $self->physical_state eq 'walking'; #sucks
}

sub apply_momentum_with_terrain_collisions{
   my $self = shift;
   my $rem = 1;
   while (1){
      my ($dir,$loc, $portion) = $self->blob->terrain_collisions( 
         $self->x, $self->x+$self->size,
         $self->y, $self->y+$self->size,
         $self->hmoment * $rem, $self->vmoment * $rem,
      );
      $self->x($self->x + ($self->hmoment * $rem * ($portion || 1)));
      $self->y($self->y + ($self->vmoment * $rem * ($portion || 1)));
      $rem *= (1-$portion) if $portion;
      last unless defined $dir;
   }
}

sub do{
   my $self = shift;
   $self->apply_friction;
   $self->apply_push;
   $self->apply_gravity;# unless $self->on_ground;
   $self->apply_momentum_with_terrain_collisions();
}

1
