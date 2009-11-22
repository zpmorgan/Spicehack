use Modern::Perl;

use Test::More;

plan tests=>30;

use_ok 'Platformer::Map::Blob';
use_ok 'Platformer::Entity';
use lib 't/lib';
use_ok 'neuPlatformer'; #neutered implementation

my $terrain = [
   [qw/1 1 1 1 1 1/],
   [qw/1 0 0 0 0 1/],
   [qw/1 0 0 0 0 1/],
   [qw/1 0 0 0 0 1/],
   [qw/1 0 0 0 0 1/],
   [qw/1 1 1 1 1 1/],
];

my $P = Platformer->new();
my $B = Platformer::Map::Blob->new (terrain=>$terrain, size=>6, );

#1st, test blob's collision detection: rects with momentum vs. terrain

# @c = $B->terrain_collisions ($x1,$x2,$y1,$y2, $hm,$vm);
my ($dir,$loc,$portion);
($dir,$loc,$portion) = $B->terrain_collision (2,2,3,3,0,0);
ok (!$dir, 'no collision while no momentum');

($dir,$loc,$portion) = $B->terrain_collision (2,2,3,3,.3,.3);
ok (!$dir, 'no collision into empty space (down,right)');

($dir,$loc,$portion) = $B->terrain_collision (2,2,3,3,-.3,-.3);
ok (!$dir, 'no collision into empty space (up,left)');

($dir,$loc,$portion) = $B->terrain_collision (1.1,1.1,2,2, 0,-.2);
is ($dir, 'h', 'hit ceiling');
is ($loc, '1', 'ceiling at line "y=1"');
is ($portion, '0.5', 'ceiling at half of this frame\'s movement');

($dir,$loc,$portion) = $B->terrain_collision (1.1,3.9,2,4.9, 0,.4);
is ($dir, 'h', 'hit floor');
is ($loc, '5', 'floor at line "y=1"');
like ($portion, qr'(0.25|0.249999)', 'floor at quarter of this frame\'s movement');



#Test entity's collisions with movement and such

my $E = Platformer::Entity->new (name => 'joey', size=>1, x=>2, y=>2, blob=>$B, platformer=>$P);

is ($E->x, 2);
is ($E->y, 2);
is ($E->vmoment, 0,'0th frame forcelessness');
$E->do();
is ($E->x, 2);
is ($E->y, 2);
is ($E->vmoment, Platformer::Entity->GRAVITY(), 'effect of gravity on momentum for 1 frame');
#$E->do();
#$E->do();
$E->do();
is ($E->x, 2);
is ($E->y, 2+Platformer::Entity->GRAVITY(), 'effect of gravity on v position');
is ($E->vmoment, 2 * Platformer::Entity->GRAVITY(), 'effect of gravity on momentum for 2 frames');

$E->do() for (1..50);
is ($E->x, 2, 'x after drop == same as before');
is ($E->y, 4, 'y after drop == floor-1');
$P->mouse_x(300);
$E->begin_push('l');
#$E->forces->{lpush} = 1;
$E->do();
is ($E->x, 2, '1st frame after applying hforce; should not have moved');
is ($E->y, 4, '1st frame after applying hforce; should not have moved');
$E->do();
is ($E->y, 4, '2nd frame after applying hforce; should not have moved vertically');
$E->do();
$E->do();
is ($E->y, 4, '4th frame after applying hforce; should not have moved vertically');

$E->do() for (1..4);
is ($E->y, 4, 'mv more horizontally, not vertically');

$E->do() for (1..50);

is ($E->x, 1, 'walked into wall (x beside wall)');
is ($E->y, 4, 'walked into wall (y on ground)');
#diag ($E->y);


