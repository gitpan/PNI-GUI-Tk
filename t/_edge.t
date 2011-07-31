use strict;
use PNI::GUI::Tk::Edge;
use Test::More;

ok 1;

done_testing;
__END__

use PNI;
use PNI::Canvas;
use PNI::GUI::Tk::Controller;
use PNI::GUI::Tk::Node;
use Test::More;

my $canvas   = PNI::Canvas->new;
my $controller = PNI::GUI::Tk::Controller->new;
my $node     = PNI::node;
my $center_y = 10;
my $center_x = 10;
my $width    = 10;
my $height   = 10;

my $node = PNI::GUI::Tk::Node->new( 
    center_y => $center_y,
    center_x => $center_x,
	controller => $controller, 
    height   => $height,
    node     => $node,
    width    => $width,
);
isa_ok $node ,'PNI::GUI::Tk::Node';


