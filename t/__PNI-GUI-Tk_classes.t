use strict;
use Test::More;

use_ok($_) for qw(
  PNI::GUI::Tk
  PNI::GUI::Tk::Canvas
  PNI::GUI::Tk::Scenario
  PNI::GUI::Tk::Scenario::Link
  PNI::GUI::Tk::Scenario::Node
  PNI::GUI::Tk::Menu
  PNI::GUI::Tk::Window
);

# checking inheritance
isa_ok 'PNI::GUI::Tk', 'PNI::GUI';
isa_ok( "PNI::GUI::Tk::$_", 'PNI::GUI::Tk::Item' ) for qw(
  Canvas
  Menu
  Window
);
isa_ok 'PNI::GUI::Tk::Scenario', 'PNI::Scenario';
isa_ok( 'PNI::GUI::Tk::Scenario::Link', $_ )
  for ( 'PNI::Scenario::Link', 'PNI::GUI::Tk::Scenario::Link' );
isa_ok( 'PNI::GUI::Tk::Scenario::Node', $_ )
  for ( 'PNI::Scenario::Node', 'PNI::GUI::Tk::Scenario::Node' );

# checking subs
can_ok( 'PNI::GUI::Tk', $_ ) for qw(
  new
  add_window
);
can_ok( 'PNI::GUI::Tk::Canvas', $_ ) for qw(
  new
  _on_double_click
  add_node
);
can_ok( 'PNI::GUI::Tk::Item', $_ ) for qw(
  new
  get_scenario
);
can_ok( 'PNI::GUI::Tk::Menu', $_ ) for qw(
  new
);
can_ok( 'PNI::GUI::Tk::Scenario', $_ ) for qw(
  new
  add_link
  add_node
  get_canvas
  get_window
);
can_ok( 'PNI::GUI::Tk::Scenario::Link', $_ ) for qw(
  new
);
can_ok( 'PNI::GUI::Tk::Scenario::Node', $_ ) for qw(
  new
  _on_input_enter
  _on_output_enter
  _on_move
  _on_slot_leave
  add_input
  add_output
  get_tk_tag
);
can_ok( 'PNI::GUI::Tk::Window', $_ ) for qw(
  new
  get_canvas
  get_menu
);

done_testing;
