use strict;
use Test::More;
use PNI::GUI::Tk;
use PNI::GUI::Tk::Window;
use PNI::GUI::Tk::Scenario;

my $gui      = PNI::GUI::Tk->new;
my $scenario = PNI::GUI::Tk::Scenario->new;
my $window   = PNI::GUI::Tk::Window->new( gui => $gui, scenario => $scenario );
isa_ok $window, 'PNI::GUI::Tk::Window';

isa_ok $window->get_canvas, 'PNI::GUI::Tk::Canvas', 'get_canvas';
isa_ok $window->get_menu,   'PNI::GUI::Tk::Menu',   'get_menu';

ok PNI::RUN;

# wait a moment so user can see the window
sleep 1;

done_testing;
