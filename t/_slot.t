use strict;
use PNI;
use PNI::GUI::Tk::App;
use PNI::GUI::Tk::Controller;
use PNI::GUI::Tk::Node;
use PNI::GUI::Tk::Slot;
use Test::More;

my $app        = PNI::GUI::Tk::App->new;
my $controller = PNI::GUI::Tk::Controller->new( app => $app );
my $node       = PNI::GUI::Tk::Node->new(
    center_y   => 0,
    center_x   => 0,
    controller => $controller,
    height     => 0,
    node       => PNI::node,
    width      => 0,
);

my $slot = PNI::GUI::Tk::Slot->new( node => $node );
isa_ok $slot, 'PNI::GUI::Tk::Slot';

is $slot->get_node, $node;

done_testing;
__END__

