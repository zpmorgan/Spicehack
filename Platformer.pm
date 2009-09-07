package Platformer;
use Platformer::Tile;
use Platformer::Map;
use Platformer::Entity;
use Platformer::Viewport;
use Modern::Perl;
use Moose;

use OpenGL ':all';
use OpenGL::Image;
die "You need the perlmagick" unless OpenGL::Image::HasEngine('Magick');

#this has an opengl window, for starters.
#It should somehow handle the entire game world. 
# - the map should be a complicated object, to dynamically generate 
#      space & freeze portions as needed, based on viewport data
# - I suppose the map or the viewport itself should return list of active entities as required.

my %textures;

has main => (
   is => 'rw', isa => 'Platformer::Entity',
   lazy=>1,
   default => sub {$_[0]->main_entity()},
);
has 'map' => (
   is => 'rw',
   isa => 'Platformer::Map', 
   default => sub {Platformer::Map->new(platformer=>$_[0])},
);
has viewport => (
   is => 'rw',
   isa => 'Platformer::Viewport', 
   lazy => 1,
   default => sub {Platformer::Viewport->new (
         map => $_[0]->map, 
         width => $_[0]->xsize,
         height=> $_[0]->ysize)},
);


has name => (is => 'ro', isa => 'Str', default=>'Spicehack');
has window => ( is => 'rw');
has xsize => ( is => 'ro', isa => 'Int');
has ysize => ( is => 'ro', isa => 'Int');

#has entities => (is => 'ro', isa => 'ArrayRef', default => sub{[]});


has params => (is => 'ro', isa => 'HashRef', default => sub{{}});


sub BUILD{
   my $self = shift;
   
   #initialize & set up glut & opengl stuff;
   #glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH);  
   glutInitWindowSize($self->xsize,$self->ysize);
   glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH | GLUT_ALPHA);
   glutInit();
   my $idWindow = glutCreateWindow($self->name);
   glClearColor(0.0, 0.0, 0.0, 0.0);
   glClearDepth(1.0);
   
   glutIgnoreKeyRepeat(1);
   glutKeyboardFunc   (sub {$self->key_press(@_)} );
   glutKeyboardUpFunc (sub {$self->key_release(@_)} );
   glutPassiveMotionFunc (sub {$self->passive_motion(@_)} );
   #glutSpecialFunc(\&special_key_press);
   glutIdleFunc(sub{$self->update});
   glutDisplayFunc(sub{$self->RenderScene});
}

sub run{
   glutMainLoop();
}


sub update{
   my $self = shift;
   
   for my $ent ($self->map->visible_entities){
      $ent->do;
   }
   glutPostRedisplay;
}

sub RenderScene{
#   warn'foo';
   my $self = shift;
   glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
   
   glMatrixMode (GL_PROJECTION);
   glLoadIdentity ();
   glOrtho (0, $self->xsize, $self->ysize, 0, 0, 1);
   glMatrixMode (GL_MODELVIEW);
   
   my @tiles = $self->map->visible_tiles;
   for (@tiles){
      $self->draw_tile(@$_);
   }
   my @ents = $self->map->visible_entities;
   for (@ents){
      $self->draw_entity($_);
   }
   
   glutSwapBuffers;
}


sub load_texture{
   my ($self,$name) = @_;
   return $textures{$name} if defined $textures{$name};
   
   my $n= glGenTextures_p(1); #'name' to opengl
   glBindTexture(GL_TEXTURE_2D, $n);
    #glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
    #glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
    #glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,
    #               GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,
                   GL_NEAREST);
   my $image= new OpenGL::Image(engine=>'Magick', source=>"$name.png");
   my ($ifmt, $fmt, $type) = 
         $image->Get('gl_internalformat','gl_format','gl_type');
   my($w,$h) = $image->Get('width','height');
   glTexImage2D_c(GL_TEXTURE_2D, 0, $ifmt, $w, $h, 
         0, $fmt, $type, $image->Ptr());
   $textures{$name} = $n;
   return $n;
}

sub draw_entity{
   my ($self, $ent) = @_;
   my $size = $ent->size * 32;
   my $n = $ent->num;
   my $x = $ent->x * 32;#todo: transformation in viewport class
   my $y = $ent->y * 32;
   draw_thing($x,$y, $size, $n);
   #die $ent->name;
}

sub draw_tile{
   my ($self, $row,$col, $tile) = @_;
   my $size = 32;
   my $n = $tile->num;
   my $x = $col*$size;
   my $y = $row*$size;
   draw_thing($x,$y, $size, $n);
}

sub draw_thing{
   my ($x,$y, $size, $n) = @_;
   glEnable(GL_TEXTURE_2D);
   glBindTexture(GL_TEXTURE_2D, $n);
   glBegin(GL_QUADS);
   glTexCoord2f(0,1);
   glVertex3f($x, $y, 0);
   glTexCoord2f(1,1);
   glVertex3f($x+$size, $y, 0);
   glTexCoord2f(1,0);
   glVertex3f($x+$size, $y+$size, 0);
   glTexCoord2f(0,0);
   glVertex3f($x, $y+$size, 0);
   glEnd();
}


sub random_monster{
   my ($self) = @_;
   my $monst = Platformer::Entity->new (
      name => 'gridbug', 
      size=>1, 
      platformer => $_[0],
      blob => $_[0]->map->main_blob,
   );
   return $monst;
}

sub main_entity{
   my ($self) = @_;
   my $ent = Platformer::Entity->new (
      name => $self->params->{main}{name},
      size => $self->params->{main}{size},
      platformer => $_[0],
      blob => $_[0]->map->main_blob,
   );
   return $ent;
}

has keys_pressed => (is=>'ro',isa=>'HashRef',default=>sub{{}});
has mouse_x => (is=>'rw',isa=>'Int', default=>200);
has mouse_y => (is=>'rw',isa=>'Int', default=>200);

sub key_press{
   my ($self, $key) = @_;
   $key = chr $key;
   $self->keys_pressed->{$key} = 1;
   if ($key eq 'a'){
      $self->main->begin_push('l');
   }
   elsif ($key eq 'd'){
      $self->main->begin_push('r');
   }
   elsif ($key eq 'w'){
      $self->main->jump();
   }
}
sub key_release{
   my ($self, $key) = @_;
   $key = chr $key;
   $self->keys_pressed->{$key} = 0;
   if ($key eq 'a'){
      $self->main->stop_push('l');
   }
   elsif ($key eq 'd'){
      $self->main->stop_push('r');
   }
}

sub passive_motion{
   my ($self, $x,$y) = @_;
   $self->mouse_x($x);
   $self->mouse_y($y);
   $self->main->calc_push();
   #say $x,$y
}

1;
