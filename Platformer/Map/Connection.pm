package Platformer::Map::Connection;
use Modern::Perl;
use Moose;

#This class is for connections between blobs.
#Each connection links between 2 blobs, 
# and is in some direction (h or v)
# and is either open or closed, i guess..

has dir => (is=>'ro', isa=>'Str');#h or v
has blobs => (is=>'ro', isa=>'HashRef', default => sub{[]});




