package PNI::GUI::Tk::Input;  # TODO rename this class to PNI::GUI::Tk::Slot::In
use strict;
use base 'PNI::GUI::Tk::Slot';
use PNI::Error;
use PNI::GUI::Tk::Canvas::Rectangle;

sub new {
    my $self = shift->SUPER::new(@_);
    my $arg  = {@_};

    $self->add('edge');

    # slot is required
    my $slot = $arg->{slot}
      or return PNI::Error::missing_required_argument;

    # $slot must be a PNI::Slot::In
    $slot->isa('PNI::Slot::In')
      or return PNI::Error::invalid_argument_type;

    $self->add( slot => $slot );

    $self->default_tk_bindings;

    return $self;
}

sub default_tk_bindings {
    my $self         = shift;
    my $border_tk_id = $self->get_border->get_tk_id;
    my $tk_canvas    = $self->get_tk_canvas;

    $tk_canvas->bind( $border_tk_id, '<ButtonRelease-1>' => undef );
    $tk_canvas->bind( $border_tk_id, '<Double-Button-1>' => undef );
    $tk_canvas->bind( $border_tk_id, '<Enter>' => [ \&show_info, $self ] );
    $tk_canvas->bind( $border_tk_id, '<Leave>' => undef );

    return 1;
}

sub del_edge { shift->set( edge => undef ); }

sub get_edge { return shift->get('edge') }

# return 1
sub hide_info {
    my $tk_canvas        = shift;
    my $self             = shift;
    my $tk_info_label_id = shift;
    my $border_tk_id     = $self->get_border->get_tk_id;

    $tk_canvas->delete($tk_info_label_id);

    $tk_canvas->bind( $border_tk_id, '<Leave>' => undef );

    return 1;
}

sub is_connected {
    my $self = shift;

    if   ( defined $self->get_edge ) { return 1; }
    else                             { return 0; }
}

# TODO non e' bellissimo, meglio come ho fatto in PNI::GUI::Tk::Edge
# return 1
sub move {
    my $self = shift;
    my ( $dx, $dy ) = @_;
    my $center_y = $self->get_center_y;
    my $center_x = $self->get_center_x;

    $self->set_center_y( $center_y + $dy );
    $self->set_center_x( $center_x + $dx );

    return 1;
}

sub set_center_y {
    my $self = shift;
    my $center_y = shift or return PNI::Error::missing_required_argument;
    $self->set( center_y => $center_y );
}

sub set_center_x {
    my $self = shift;
    my $center_x = shift or return PNI::Error::missing_required_argument;
    $self->set( center_x => $center_x );
}

sub set_edge {
    my $self = shift;
    my $edge = shift
      or return PNI::Error::missing_required_argument;
    $edge->isa('PNI::GUI::Tk::Edge')
      or return PNI::Error::invalid_argument_type;

    # TODO per ora metto questa patch
    $self->get_slot->add_edge( $edge->get_edge );

    $self->set( edge => $edge );
}

sub show_info {
    my $tk_canvas    = shift;
    my $self         = shift;
    my $border_tk_id = $self->get_border->get_tk_id;
    my $center_y     = $self->get_center_y;
    my $center_x     = $self->get_center_x;
    my $slot         = $self->get_slot;

    my $text = 'UNDEF';

    if ( $slot->is_defined ) {
        $text = $slot->get_data;
    }

    my $tk_info_label_id =
      $tk_canvas->createText( $center_x, $center_y - 20, -text => $text, );

    $tk_canvas->bind( $border_tk_id,
        '<Leave>' => [ \&hide_info, $self, $tk_info_label_id ] );

    return 1;
}

1;
__END__

=head1 NAME

PNI::GUI::Tk::Input - 

=head1 METHODS

=head2 C<default_tk_bindings>

=head2 C<get_border>

=head2 C<get_controller>

=head2 C<get_tk_canvas>

=head2 C<show_info>

=cut

