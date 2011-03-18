use strict;
use Test::More;
use PNI::GUI::Tk;
use PNI::GUI::Tk::Item;
use PNI::GUI::Tk::Scenario;

my $gui      = PNI::GUI::Tk->new;
my $scenario = PNI::GUI::Tk::Scenario->new;

# create an abstract item, since there is no check on the tk parameter
# cause it should be some Tk::* but there is no stricture by now,
# so it could be an integer as well, for example a tk id
my $item = PNI::GUI::Tk::Item->new(
    gui      => $gui,
    scenario => $scenario,
    tk       => 1
);
isa_ok $item, 'PNI::GUI::Tk::Item';

is $item->get_scenario, $scenario, 'get_scenario';

done_testing;
