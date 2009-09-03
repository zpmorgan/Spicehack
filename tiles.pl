#!/usr/bin/perl
use Modern::Perl;

#this displays a few crappy tiles with opengl.

package Map;
use Moose;

has 'grid' => (
   is => 'ro',
   isa => 'ArrayRef',
);
has 'h' => (
   is => 'ro',
   isa => 'Int'
);
has 'w' => (
   is => 'ro',
   isa => 'Int'
);


package Game;
use Moose;

has 'player' => (
   is => 'rw',
   isa => 'Player',
);

has 'map' => (
   is => 'ro',
   isa => 'Map',
);


package Tile;
use Moose;
use OpenGL::Image;

has 'name' => (
   is => 'ro',
   isa => 'Str',
);

sub BUILD{
   my $self = shift;
   #my $tex = new OpenGL::Image(engine=>'Magick', source=>$self->texfile);
}

package Entity;
use Moose;

has 'name' => (
   is => 'ro',
   isa => 'Str',
);
has 'x' => (
   is => 'rw',
   isa => 'Num',
);
has 'y' => (
   is => 'rw',
   isa => 'Num',
);


package main;


use OpenGL qw(:all);
use OpenGL::Image;
die "You need the perlmagick" unless OpenGL::Image::HasEngine('Magick');

my %textures;

my $game = Game->new(
   map => Map->new(
      'h' => 5, 'w' => 5, grid => []
   ),
);



my ($XSize,$YSize) = (640, 480);

#glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH);  
glutInitWindowSize($XSize,$YSize);
glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH | GLUT_ALPHA);
glutInit();
my $idWindow = glutCreateWindow('Spicehack');

glClearColor(0.0, 0.0, 0.0, 0.0);
glClearDepth(1.0);

#glpOpenWindow(width => 400, height => 400,);
              #attributes => [GLX_RGBA,GLX_DOUBLEBUFFER]);


#teapot demo is useful:
# Register the callback function to do the drawing.
glutDisplayFunc(\&RenderScene);

# If there's nothing to do, draw.
glutIdleFunc(\&RenderScene);

# It's a good idea to know when our window's resized.
#glutReshapeFunc(\&cbResizeScene);

# And let's get some keyboard input.
glutKeyboardFunc(\&KeyPressed);
glutSpecialFunc(\&SpecialKeyPressed);

# Pass off control to OpenGL.
# Above functions are called as appropriate.


my $tilesize = 64;
   

my @map = (
   [qw[0 0 0 0 0 0 0 0]],
   [qw[0 0 0 0 0 0 0 0]],
   [qw[0 0 0 0 0 1 0 0]],
   [qw[0 0 1 1 1 1 1 0]],
   [qw[0 0 0 0 0 0 0 0]],
   [qw[0 0 0 0 0 0 0 0]],
);

my @tiles;
$tiles[0] = newtile ('nothing');
$tiles[1] = newtile ('grassycrap');

my @entities = new Entity(name => 'mrflash', x=>3,y=>1);
loadtex('mrflash');

sub newtile{
   my $name = shift;
   loadtex ($name);
   my $tile = new Tile (name => $name);
   return $tile;
}

sub loadtex{
   my $name = shift;
   my $texnum= glGenTextures_p(1); #'name' to opengl
   glBindTexture(GL_TEXTURE_2D, $texnum);
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
   $textures{$name} = $texnum;
}

glutMainLoop();



sub RenderScene{
   glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
   
   glMatrixMode (GL_PROJECTION);
   glLoadIdentity ();
   glOrtho (0, $XSize, $YSize, 0, 0, 1);
   glMatrixMode (GL_MODELVIEW);
   
   my $i=0;
   for my $row (@map){
      my $j=0;
      for my $cell (@$row){
         my $tile = $tiles[$cell];
         drawtile($i,$j,$tile);
         $j++
      }
      $i++
   }
   
   for my $e (@entities){
      drawent($e);
   }
   
   #glClear GL_COLOR_BUFFER_BIT;
   glutSwapBuffers;
}

sub KeyPressed{
   
}
sub SpecialKeyPressed{
   my ($k,$x,$y) = @_;
   given ($k){
      when ($_ == GLUT_KEY_LEFT){ warn 'left'}
      when ($_ == GLUT_KEY_RIGHT){ warn 'right'}
      
   }
}

sub drawent{
   my $ent = shift;
   my $name = $ent->name;
   my $n = $textures{$name};
   my $y = int ($ent->y*32);
   my $x = int ($ent->x*32);
   glEnable(GL_TEXTURE_2D);
   glBindTexture(GL_TEXTURE_2D, $n);
   glBegin(GL_QUADS);
   glTexCoord2f(0,1);
   glVertex3f($x, $y, 0);
   glTexCoord2f(1,1);
   glVertex3f($x+$tilesize, $y, 0);
   glTexCoord2f(1,0);
   glVertex3f($x+$tilesize, $y+$tilesize, 0);
   glTexCoord2f(0,0);
   glVertex3f($x, $y+$tilesize, 0);
   glEnd();

}

sub drawtile{
   my ($row,$col, $tile) = @_;
   my $x = $col*$tilesize;
   my $y = $row*$tilesize;
   my $n= $textures{$tile->name};
   glEnable(GL_TEXTURE_2D);
   glBindTexture(GL_TEXTURE_2D, $n);
   glBegin(GL_QUADS);
   glTexCoord2f(0,1);
   glVertex3f($x, $y, 0);
   glTexCoord2f(1,1);
   glVertex3f($x+$tilesize, $y, 0);
   glTexCoord2f(1,0);
   glVertex3f($x+$tilesize, $y+$tilesize, 0);
   glTexCoord2f(0,0);
   glVertex3f($x, $y+$tilesize, 0);
   glEnd();

}


