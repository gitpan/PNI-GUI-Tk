package PNI::GUI::Tk::Node_inspector;
use strict;
use base 'PNI::Item';
use Tk::Toplevel;

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

    my $window = $controller->get_window->get_tk_main_window->Toplevel;
    $self->add( window => $window );
}

1;
__END__
