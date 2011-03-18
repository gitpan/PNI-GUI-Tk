use strict;
use Test::More;
use PNI::GUI::Tk;
use PNI::GUI::Tk::Canvas;
use PNI::GUI::Tk::Window;
use PNI::GUI::Tk::Scenario;

my $gui      = PNI::GUI::Tk->new;
my $scenario = PNI::GUI::Tk::Scenario->new;
my $window   = PNI::GUI::Tk::Window->new( gui => $gui, scenario => $scenario );

# i need to pass a window to the canvas constructor
# this is the only way i found
# even if the window has its own canvas

my $canvas = PNI::GUI::Tk::Canvas->new( gui => $gui, window => $window );
isa_ok $canvas, 'PNI::GUI::Tk::Canvas';
isa_ok $canvas->tk, 'Tk::Canvas';

TODO: {
    local $TODO = 'add_node';

    # to test add_node it would be necessary to simulate an XEvent
    #
    # this is the snippet used in the sub add_node
    #
    #  my $center_x = $self->tk->XEvent->x;
    #  my $center_y = $self->tk->XEvent->y;
    #

    #isa_ok $canvas->add_node,'PNI::GUI::Tk::Canvas::Node';

    ok(0);

    #is($canvas->add_node,undef,'add_node with no Tk event');
}

is $canvas->get_scenario, $scenario, 'get_scenario';

done_testing;

