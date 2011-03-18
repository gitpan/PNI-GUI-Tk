use strict;
use Test::More;
use PNI::GUI::Tk;
use PNI::GUI::Tk::Scenario;
use PNI::GUI::Tk::Window;

my $gui      = PNI::GUI::Tk->new;
my $scenario = PNI::GUI::Tk::Scenario->new;
isa_ok $scenario, 'PNI::GUI::Tk::Scenario';

is $scenario->get_window, undef, 'get_window before set_window';
is $scenario->get_canvas, undef, 'get_canvas before set_canvas';

# add a window to scenario
my $window = PNI::GUI::Tk::Window->new( gui => $gui, scenario => $scenario );

is $scenario->get_window, $window, 'get_window';
is $scenario->get_canvas, $window->get_canvas, 'get_canvas';

isa_ok $scenario->add_node(
    node_type => 'Perlvar::Perl_version',
    center    => [ 10, 10 ]
  ),
  'PNI::GUI::Tk::Scenario::Node';

done_testing;
__END__

