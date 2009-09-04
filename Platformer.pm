package Platformer;
use Platformer::Tile;
use Platformer::Map;
use Modern::Perl;
use Moose;

use OpenGL ':all';
use OpenGL::Image;
die "You need the perlmagick" unless OpenGL::Image::HasEngine('Magick');

#this has an opengl window, for starters.
#It should somehoe handle tne entire game world. 
# - the map should be a complicated object, to dynamically generate 
#      space & freeze portions as needed, and handle the viewport
# - I suppose the map or the viewport itself should return list of active entities as required.

my %textures;

has 'map' => (
   is => 'rw',
   isa => 'Platformer::Map', 
   default => sub{Platformer::Map->new(platformer=>$_[0])},
);
has viewport => (
   is => 'rw',
   isa => 'Platformer::Map', 
   lazy => 1,
   default => sub{ Platformer::Viewport->new (map => $_[0]->map) },
);

has name => (is => 'ro', isa => 'Str', default=>'Spicehack');
has window => ( is => 'rw');
has xsize => ( is => 'ro', isa => 'Int');
has ysize => ( is => 'ro', isa => 'Int');

has entities => (is => 'ro', isa => 'ArrayRef', default => sub{[]});

#initialize & set up glut & opengl stuff;
sub BUILD{
   my $self = shift;
   #glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH);  
   glutInitWindowSize($self->xsize,$self->ysize);
   glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH | GLUT_ALPHA);
   glutInit();
   my $idWindow = glutCreateWindow($self->name);
   glClearColor(0.0, 0.0, 0.0, 0.0);
   glClearDepth(1.0);
   
   #glutKeyboardFunc(\&KeyPressed);
   #glutSpecialFunc(\&SpecialKeyPressed);
   glutIdleFunc(sub{$self->update});
   glutDisplayFunc(sub{$self->RenderScene});
}

sub run{
   glutMainLoop();
}


sub update{
   my $self = shift;
   
   for my $ent (@{$self->entities}){
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
      draw_tile(@$_);
   }
   
   glutSwapBuffers;
}


sub load_texture{
   my ($self,$name) = @_;
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

sub draw_tile{
   my ($row,$col, $tile) = @_;
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





1;
