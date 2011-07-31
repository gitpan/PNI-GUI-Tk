package PNI::GUI::Tk::Canvas::Item;
use strict;
use warnings;
use base 'PNI::Item';
use PNI::Error;

sub new {
    my $class = shift;
    my $arg   = {@_};
    my $self  = $class->SUPER::new(@_)
      or return PNI::Error::unable_to_create_item;

    # $canvas is required
    my $canvas = $arg->{canvas}
      or return PNI::Error::missing_required_argument;

    # $canvas must be a PNI::GUI::Tk::Canvas
    $canvas->isa('PNI::GUI::Tk::Canvas')
      or return PNI::Error::invalid_argument_type;

    $self->add( canvas => $canvas );

    $self->add('tk_id');

    return $self;
}

sub configure {
    my $self = shift;
    $self->get_tk_canvas->itemconfigure( $self->get_tk_id, @_ );
}

sub delete {
    my $self = shift;
    $self->get_tk_canvas->delete( $self->get_tk_id );
}

# return $canvas: PNI::GUI::Tk::Canvas
sub get_canvas { shift->get('canvas') }

# return $tk_canvas: Tk::Canvas
sub get_tk_canvas { shift->get_canvas->get_tk_canvas }

# return $tk_id
sub get_tk_id { shift->get('tk_id') }

1;
__END__

=head1 NAME

PNI::GUI::Tk::Canvas::Item - Tk::Canvas item base class

=head1 METHODS

=head2 C<configure>

=head2 C<delete>

=head2 C<get_canvas>

=head2 C<get_tk_id>

=cut
