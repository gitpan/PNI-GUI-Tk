package PNI::GUI::Tk::Canvas::Rectangle;
use strict;
use warnings;
use base 'PNI::GUI::Tk::Canvas::Item';
use PNI::Error;

sub new {
    my $self  = shift->SUPER::new(@_)
      or return PNI::Error::unable_to_create_item;
    my $arg   = {@_};

    my $y1 = $arg->{y1};
    $self->add( y1 => $y1 );

    my $y2 = $arg->{y2};
    $self->add( y2 => $y2 );

    my $x1 = $arg->{x1};
    $self->add( x1 => $x1 );

    my $x2 = $arg->{x2};
    $self->add( x2 => $x2 );

    my $tk_canvas = $self->get_tk_canvas;
    my $tk_id = $tk_canvas->createRectangle( $x1, $y1, $x2, $y2 );
    $self->set( tk_id => $tk_id );

    return $self;
}

1;
__END__

=head1 NAME

PNI::GUI::Tk::Canvas::Rectangle - Tk::Canvas rectangle item

=cut

