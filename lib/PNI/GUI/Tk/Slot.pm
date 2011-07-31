package PNI::GUI::Tk::Slot;
use strict;
use base 'PNI::GUI::Slot';

sub new {
    my $self = shift->SUPER::new(@_);
    my $arg  = {@_};

    my $node = $self->get_node;

    my $center_y = $arg->{center_y};
    $self->add( center_y => $center_y );

    my $center_x = $arg->{center_x};
    $self->add( center_x => $center_x );

    # $half_side defaults to 4
    my $half_side = $arg->{half_side} || 4;
    $self->add( half_side => $half_side );

    my $canvas        = $self->get_canvas;
    my $tk_canvas     = $self->get_tk_canvas;
    my $y1            = $center_y - $half_side;
    my $y2            = $center_y + $half_side;
    my $x1            = $center_x - $half_side;
    my $x2            = $center_x + $half_side;
    my @border_config = qw( -activefill black -fill gray );

    my $border = PNI::GUI::Tk::Canvas::Rectangle->new(
        canvas => $canvas,
        y1     => $y1,
        y2     => $y2,
        x1     => $x1,
        x2     => $x2,
    ) or return PNI::Error::unable_to_create_item;
    $border->configure(@border_config);

    # TODO verifica se serve mettere l'id del node o si puo mettere il self id
    #      oppure addirittura non serve neanche
    $tk_canvas->addtag( $node->id, 'withtag', $border->get_tk_id );
    $self->add( tk_id  => $border->get_tk_id );
    $self->add( border => $border );

    return $self;
}

# return $canvas : PNI::GUI::Tk::Canvas
sub get_canvas { shift->get_controller->get_canvas; }

# return $border : PNI::GUI::Tk::Canvas::Rectangle
sub get_border { shift->get('border') }

sub get_center_y { shift->get('center_y') }

sub get_center_x { shift->get('center_x') }

# return $controller : PNI::GUI::Tk::Controller
sub get_controller { shift->get_node->get_controller }

sub get_name { shift->get_slot->get_name }

sub get_slot { shift->get('slot') }

# return $tk_canvas: PNI::GUI::Tk::Canvas
sub get_tk_canvas { shift->get_controller->get_tk_canvas }

sub get_tk_id { shift->get('tk_id') }

1;
__END__

=head1 NAME

PNI::GUI::Tk::Slot

=cut

