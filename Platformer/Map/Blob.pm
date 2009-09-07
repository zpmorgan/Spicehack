package Platformer::Map::Blob;
use Modern::Perl;
use Moose;

#map is composed of blobs to make it seem less rigidly structured into layers,etc.
#perhaps blobs should be procedurally predetermined, but not generated until player goes there.

has 'map' => (is => 'ro', isa => 'Platformer::Map');
has size => (is => 'ro', isa => 'Int', default => 15);
has 'x' => (is => 'ro', isa => 'Int');
has 'y' => (is => 'ro', isa => 'Int');

#when it must link to a nearby blob, or be elongated in some direction,
#or have certain areas as solid or space
has gen_constraints => (
   is => 'ro',
   isa => 'HashRef',
   default=>sub{{}},
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

has entities => (is=>'ro', isa=>'ArrayRef', 
   lazy=>1,
   default=>sub {[$_[0]->default_entities]} );

has connections => (is=>'ro', isa=>'ArrayRef', default=>sub{[]});


sub generate{
   my $self = shift;
   my $size = $self->size;
   my $iterations = 3;
   my $amountWalls = .45;
   my $terrain = [map {[map {rand() < $amountWalls || 0} (1..$size)]} (1..$size)];
   my @next;
   
   my ($solid, $space, $entry);
   if ($self->gen_constraints){
      ($solid, $space, $entry) = @{$self->gen_constraints}{qw/solid space entry/};
   }
   $solid ||= [];
   $space ||= [];
   
   my $do_borders = sub{
      for (0..$size-1){
         $next[0][$_] = 1;
         $next[$size-1][$_] = 1;
         $next[$_][0] = 1;
         $next[$_][$size-1] = 1;
      }
   };
   
   for (1..$iterations){
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
      for (@$solid){
         my ($col,$row) = @$_;
         $next[$row][$col] = 1;
      }
      for (@$space){
         my ($col,$row) = @$_;
         $next[$row][$col] = 0;
      }
      $terrain = [@next];
   }
   #$self->decorate($terrain);
   return $terrain;
}

sub default_entities{ #for now, just add 1 monster
   my $self = shift;
   my @ents;
   my $terrain = $self->terrain;
   
   my $monster = $self->map->platformer->random_monster();
   $self->find_place_for_entity($monster, {rows=>[3,8],cols=>[3,8]} );
   push @ents, $monster;
   
   my $entry = $self->gen_constraints->{entry};
   if ($entry){
      my ($col,$row) = @$entry;
      my $main = $self->map->platformer->main;
      $main->x($col);
      $main->y($row);
      push @ents, $main;
   }
   
   return @ents;
}

sub area_is_space{
   my ($self,$row,$col,$h,$w) = @_;
   for my $r($row..$row+$h-1){
      for my $c($col..$col+$w-1){
         return 0 if $self->terrain->[$r][$c];
      }
   }
   1
}
sub find_place_for_entity{
   my ($self,$entity, $rect) = @_;
   my $h = $entity->h;
   my $w = $entity->w;
   
   my $mincol = $rect->{cols}[0];
   my $minrow = $rect->{rows}[0];
   my $maxcol = $rect->{cols}[1]-$w+1;
   my $maxrow = $rect->{rows}[1]-$h+1;
   my $cols = $maxcol-$mincol;
   
   my ($row,$col);
   $col = $mincol + int rand($cols);
   RANDPICK:
   for (1..$cols){
      $col = (($col-$mincol+13)%$cols)+$mincol; #lol, columns cycle randomishly
      my $r=$maxrow;#search for space from bottom to top
      until ($r < $minrow){
         if ($self->area_is_space($r,$col,$h,$w)){
            $row=$r;
            last RANDPICK;
         }
         $r--
      }
   }
   die 'boo' unless defined $row;
   $entity->y($row);#wrong; doesnt offset with blob coordinates. 
   $entity->x($col);
   return $entity;
   #push @{$self->entities}, $entity;
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

sub solid_tile{
   my ($self, $x,$y) = @_;
   return 0 unless $self->terrain->[$y][$x];
   return [int $x,int $y];
}

1
