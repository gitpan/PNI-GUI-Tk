package PNI::GUI::Tk::Canvas::Window;
use strict;
use warnings;
use base 'PNI::GUI::Tk::Canvas::Item';
use PNI::Error;

sub new {
    my $class = shift;
    my $arg   = {@_};
    my $self  = $class->SUPER::new(@_)
      or return PNI::Error::unable_to_create_item;

    my $window = $arg->{window};
    $self->add( window => $window );

    my $y = $arg->{y};
    $self->add( y => $y );

    my $x = $arg->{x};
    $self->add( x => $x );

    $self->set( tk_id => $self->get_tk_canvas->createWindow( $x, $y, -window => $window ) );

    return $self;
}

1;
__END__

=head1 NAME

PNI::GUI::Tk::Canvas::Window - Tk::Canvas window item

=cut
