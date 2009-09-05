package Platformer::Map::Blob;
use Modern::Perl;
use Moose;

#map is composed of blobs to make it seem less rigidly structured into layers,etc.
#perhaps blobs should be procedurally predetermined, but not generated until player goes there.

has 'map' => (is => 'ro', isa => 'Platformer::Map');
has size => (is => 'ro', isa => 'Int', default => 12);
has 'x' => (is => 'ro', isa => 'Int');
has 'y' => (is => 'ro', isa => 'Int');

#when it must link to a nearby blob, or be elongated in some direction,
#or have certain areas as solid or space
has gen_constraints => (
   is => 'ro',
   isa => 'HashRef'
);

#positive or negative
has sign => (is => 'ro', isa => 'Int');
has tiles => (
   is => 'ro',
   isa => 'ArrayRef',
   lazy => 1,
   default => sub{$_[0]->decide_tiles},
);
has terrain => (
   is => 'ro',
   isa => 'ArrayRef',
   lazy => 1,
   default => sub{$_[0]->generate},
);

has entities => (is=>'ro', isa=>'ArrayRef', default=>sub{[]});

has connections => (is=>'ro', isa=>'ArrayRef', default=>sub{[]});


sub generate{
   my $self = shift;
   my $size = $self->size;
   my $iterations = 3;
   my $amountWalls = .45;
   my $terrain = [map {[map {rand() < $amountWalls || 0} (1..$size)]} (1..$size)];
   my @next;
   
   my $do_borders = sub{
      for (0..$size-1){
         $next[0][$_] = 1;
         $next[$size-1][$_] = 1;
         $next[$_][0] = 1;
         $next[$_][$size-1] = 1;
      }
   };
   
   for (1..$iterations){
   #say join "\n", map{join'',@$_}@$terrain;
      @next = ();
      for my $row (1..$size-2){
         for my $col (1..$size-2){
            my $ct = 0;
            #count number of 1's in 3x3 proximity + itself
            for my $r ($row-1..$row+1) { for my $c ($col-1..$col+1) { $ct += 1 if $terrain->[$r][$c] } };
            $next[$row][$col] = $ct>4||0;
         }
      }
      $do_borders->();
      if ($self->gen_constraints){
         my ($solid, $empty) = @{$self->gen_constraints}{qw/solid space/};
         for (@$solid){
            my ($col,$row) = @$_;
            $next[$row][$col] = 1;
         }
         for (@$empty){
            my ($col,$row) = @$_;
            $next[$row][$col] = 0;
         }
      }
      $terrain = [@next];
   }
   $self->decorate($terrain);
   return $terrain;
}

sub decorate{ #for now, just add 1 monster
   my $self = shift;
   my $terrain = shift || $self->terrain;
   
   my $monster = $self->map->platformer->random_monster();
   my $h = $monster->h;
   my $w = $monster->w;
   my ($row,$col);
   RANDPICK:
   for (1..80){
      $row =  int rand(9);
      $col =  int rand(9);
      warn $_ . $row . $col;
      for my $r (0..$h-1){
         for my $c (0..$w-1){
            next RANDPICK if $terrain->[$row+$r][$col+$c]
         }
      }
      die if $_==80;
      last;
   }
   DROP:
   for my $r ($row..$self->size - $monster->h){#move monster down in space until it hits floor
      $row=$r;
      for my $c (0..$w-1){
         last DROP if $terrain->[$row+$h][$col+$c]
      }
   }
   $monster->y($row);#wrong; doesnt offset with blob coordinates. 
   $monster->x($col);
   push @{$self->entities}, $monster;
}



sub decide_tiles{
   my $self = shift;
   my $tiles = [
      undef,
      $self->map->brick_tile,
   ];
   return $tiles;
}

sub get_tiles{
   my $self = shift;
   my @tiles;
   for my $row (0..$self->size-1){
      for my $col (0..$self->size-1){
         if ($self->terrain->[$row][$col]==1){
            push @tiles, [$row, $col, $self->tiles->[1]]
         }
      }
   }
   return @tiles;
}

1
