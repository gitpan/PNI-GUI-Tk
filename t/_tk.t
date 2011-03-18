use strict;
use Test::More;
use PNI::GUI::Tk;

my $gui = PNI::GUI::Tk->new;
isa_ok $gui, 'PNI::GUI::Tk';
isa_ok $gui->add_window, 'PNI::GUI::Tk::Window';

done_testing;
