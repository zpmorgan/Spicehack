package Platformer;
use Modern::Perl;
use Moose;

use Platformer::Viewport;

#this is a neutered platformer object to provide mouse data to tests
#also no opengl stuff!

has mouse_x => (is => 'rw', isa=>'Int');

has viewport => (is => 'ro', isa=>'Platformer::Viewport',
      default=> sub{Platformer::Viewport->new(height=>400, width=>600)},
);


1
