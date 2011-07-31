package PNI::GUI::Tk::Window;
use strict;
use base 'PNI::Item';
use PNI;
use PNI::Error;

# TODO window title should be scenario file name

sub new {
    my $class = shift;
    my $arg   = {@_};
    my $self  = $class->SUPER::new(@_)
      or return PNI::Error::unable_to_create_item;

    # $controller is not required but should be a PNI::GUI::Tk::Controller
    my $controller = $arg->{controller};
    if ( defined $controller ) {
        $controller->isa('PNI::GUI::Tk::Controller')
          or return PNI::Error::invalid_argument_type;
    }
    $self->add( controller => $controller );

    # it is necessary to use a PNI::Node::Tk::MainWindow
    # so PNI loop and Tk mainloop can coexist
    my $main_window_node = PNI::node 'Tk::MainWindow';
    my $tk_main_window = $main_window_node->get_output('main_window')->get_data;
    $tk_main_window->protocol( 'WM_DELETE_WINDOW',
        sub { return $controller->close_window; } );
    $self->add( tk_main_window => $tk_main_window );

    ### new: __PACKAGE__ . ' id=' . $self->id
    return $self;
}

sub get_controller { return shift->get('controller'); }

# return $tk_main_window
sub get_tk_main_window { return shift->get('tk_main_window'); }

sub set_title {
    my $self  = shift;
    my $title = shift
      or return PNI::Error::missing_required_argument;

    my $tk_main_window = $self->get_tk_main_window;
    $tk_main_window->title($title);
}

1;
__END__

=head1 NAME

PNI::GUI::Tk::Window - 

=cut

