use strict;
use Test::More;
use PNI::GUI::Tk::App;
use PNI::GUI::Tk::Controller;

my $app = PNI::GUI::Tk::App->new;
my $controller = PNI::GUI::Tk::Controller->new( app => $app );
isa_ok $controller,'PNI::GUI::Tk::Controller';

isa_ok $controller->get_canvas, 'PNI::GUI::Tk::Canvas';
isa_ok $controller->get_tk_canvas, 'Tk::Canvas';

done_testing;
__END__
