package PNI::GUI::Tk::Output
  ;    # TODO rename this class to PNI::GUI::Tk::Slot::Out
use strict;
use base 'PNI::GUI::Tk::Slot';
use PNI::Error;
use PNI::GUI::Tk::Canvas::Line;
use PNI::GUI::Tk::Canvas::Rectangle;

sub new {
    my $self = shift->SUPER::new(@_);
    my $arg  = {@_};

    $self->add( edges => {} );

    # arg slot is required
    my $slot = $arg->{slot}
      or return PNI::Error::missing_required_argument;

    # arg slot must be a PNI::Slot::Out
    $slot->isa('PNI::Slot::Out')
      or return PNI::Error::invalid_argument_type;

    $self->add( slot => $slot );

    $self->default_tk_bindings;

    return $self;
}

sub add_edge {
    my $self = shift;
    my $edge = shift
      or return PNI::Error::missing_required_argument;
    $edge->isa('PNI::GUI::Tk::Edge')
      or return PNI::Error::invalid_argument_type;

    # TODO per ora metto questa patch
    $self->get_slot->add_edge( $edge->get_edge );

    $self->get('edges')->{ $edge->id } = $edge;
}

sub default_tk_bindings {
    my $self         = shift;
    my $controller   = $self->get_controller;
    my $border_tk_id = $self->get_border->get_tk_id;
    my $tk_canvas    = $self->get_tk_canvas;

    $tk_canvas->bind(
        $border_tk_id,
        '<ButtonPress-1>' => sub {
            $controller->connecting_edge($self);
        }
    );
    $tk_canvas->bind( $border_tk_id, '<Enter>' => [ \&show_info, $self ] );
    $tk_canvas->bind( $border_tk_id, '<Leave>' => undef );
}

sub del_edge {
    my $self = shift;
    my $edge = shift
      or return PNI::Error::missing_required_argument;

    delete $self->get('edges')->{ $edge->id };
}

sub get_edges { values %{ shift->get('edges') } }

# return 1
sub leave {
    my $tk_canvas        = shift;
    my $self             = shift;
    my $tk_info_label_id = shift;
    my $border_tk_id     = $self->get_border->get_tk_id;

    $tk_canvas->delete($tk_info_label_id);

    $tk_canvas->bind( $border_tk_id, '<Leave>' => undef );
}

# TODO messo cosi non serve
# return 1
#sub move {
#    my $self = shift;
#    my( $dx, $dy ) = @_;
#    my $center_y = $self->get_center_y;
#    my $center_x = $self->get_center_x;
#
#    $self->set_center_y( $center_y + $dy );
#    $self->set_center_x( $center_x + $dx );
#
#    return 1;
#}

sub set_center_y {
    my $self     = shift;
    my $center_y = shift
      or return PNI::Error::missing_required_argument;

    $self->set( center_y => $center_y );
}

sub set_center_x {
    my $self     = shift;
    my $center_x = shift
      or return PNI::Error::missing_required_argument;

    $self->set( center_x => $center_x );
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
      $tk_canvas->createText( $center_x, $center_y + 20, -text => $text, );

    $tk_canvas->bind( $border_tk_id,
        '<Leave>' => [ \&leave, $self, $tk_info_label_id ] );
}

1;
__END__

=head1 NAME

PNI::GUI::Tk::Output - 

=head1 METHODS

=head2 C<default_tk_bindings>

=head2 C<get_border>

=head2 C<get_controller>

=head2 C<get_tk_canvas>

=head2 C<show_info>

=cut

