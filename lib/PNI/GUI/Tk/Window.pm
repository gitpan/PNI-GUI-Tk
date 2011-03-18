package PNI::GUI::Tk::Window;
use strict;
use warnings;
our $VERSION = '0.11';
use base 'PNI::GUI::Tk::Item';
use PNI;
use PNI::Error;
use PNI::GUI::Tk::Canvas;
use PNI::GUI::Tk::Menu;

sub new {
    my $class = shift;
    my $arg   = {@_};

    my $gui      = $arg->{gui};
    my $scenario = $arg->{scenario};

    # it is necessary to use a PNI::Node::Tk::MainWindow
    # so PNI loop and Tk mainloop can coexist
    my $main_window_node = PNI::NODE 'Tk::MainWindow';
    my $tk_main_window = $main_window_node->get_output('main_window')->get_data;

    my $self = $class->SUPER::new(
        gui      => $gui,
        scenario => $scenario,
        tk       => $tk_main_window
    ) or return;

    $self->tk->protocol( 'WM_DELETE_WINDOW',
        sub { $self->get_gui->del_window($self); return; } );

    my $canvas = PNI::GUI::Tk::Canvas->new( window => $self )
      or return PNI::Error::unable_to_create_item;
    $self->add( canvas => $canvas );

    my $menu = PNI::GUI::Tk::Menu->new( window => $self )
      or return PNI::Error::unable_to_create_item;
    $self->add( menu => $menu );

    # tell scenario which is its window
    $self->get_scenario->set( window => $self );

    $self->add( main_window_node => $main_window_node );

    return $self;
}

sub close {
    my $self = shift;
    my $tk_main_window =
      $self->get('main_window_node')->get_output('main_window')->get_data;
    $tk_main_window->destroy;

    $self->del('main_window_node');

    $self->DESTROY;
    return 1;
}

sub get_canvas { return shift->get('canvas'); }

sub get_menu { return shift->get('menu'); }

1;

