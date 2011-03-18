use strict;
use Test::More;
use PNI::GUI::Tk;
use PNI::GUI::Tk::Window;
use PNI::GUI::Tk::Scenario;
use PNI::GUI::Tk::Scenario::Node;

my ( $x, $y ) = ( 100, 100 );
my $gui      = PNI::GUI::Tk->new;
my $scenario = PNI::GUI::Tk::Scenario->new;
my $window   = PNI::GUI::Tk::Window->new( gui => $gui, scenario => $scenario );

my $node = PNI::GUI::Tk::Scenario::Node->new(
    center   => [ $x, $y ],
    scenario => $scenario
);
isa_ok $node, 'PNI::GUI::Tk::Scenario::Node';
done_testing;
__END__

is($node->get_scenario,$scenario,'get_scenario');
is($node->get_canvas,$scenario->get_canvas,'get_canvas');

