package PNI::GUI::Tk::Node;
use strict;
use base 'PNI::GUI::Node';
use PNI::Error;
use PNI::GUI::Tk::Canvas::Rectangle;
use PNI::GUI::Tk::Canvas::Text;
use PNI::GUI::Tk::Input;
use PNI::GUI::Tk::Output;

sub new {
    my $class = shift;
    my $arg   = {@_};
    my $self  = $class->SUPER::new(@_)
      or return PNI::Error::unable_to_create_item;

    # $controller is required
    my $controller = $arg->{controller}
      or return PNI::Error::missing_required_argument;

    # $controller must be a PNI::GUI::Tk::Controller
    $controller->isa('PNI::GUI::Tk::Controller')
      or return PNI::Error::invalid_argument_type;

    $self->add( controller => $controller );

    $self->add( input => {} );

    $self->add( output => {} );

    $self->add( tk_ids => [] );

    # set default height and width
    my $height     = $self->get_height || 20;
    my $label_text = $self->get_label;
    my $width      = $self->get_width || 6 * length($label_text);
    $self->set_height($height);
    $self->set_width($width);

    my $canvas      = $self->get_canvas;
    my $center_y    = $self->get_center_y;
    my $center_x    = $self->get_center_x;
    my $half_height = $height / 2;
    my $half_width  = $width / 2;
    my $self_id     = $self->id;

    #my @slot_config     = qw( -activefill black -fill gray );
    my $slot_half_width = 4;
    my $tk_canvas       = $self->get_tk_canvas;

    my $y1 = $center_y - $half_height;
    my $y2 = $center_y + $half_height;
    my $x1 = $center_x - $half_width;
    my $x2 = $center_x + $half_width;

    my $border = PNI::GUI::Tk::Canvas::Rectangle->new(
        canvas => $canvas,
        y1     => $y1,
        y2     => $y2,
        x1     => $x1,
        x2     => $x2,
    ) or return PNI::Error::unable_to_create_item;

    #$tk_canvas->addtag( $self_id, 'withtag', $border->get_tk_id );
    $self->add_tk_id( $border->get_tk_id );
    $self->add( border => $border );

    my $text = PNI::GUI::Tk::Canvas::Text->new(
        canvas => $canvas,
        text   => $label_text,
        y      => $center_y,
        x      => $center_x,
    ) or return PNI::Error::unable_to_create_item;
    $self->add_tk_id( $text->get_tk_id );
    $self->add( text => $text );

    # draw inputs
    my @input         = $self->get_node->get_inputs;
    my $num_of_inputs = scalar @input;

    # if there is only one input, draw it in the north-est corner
    if ( $num_of_inputs == 1 ) {

        $self->add_input(
            center_y => $y1,
            center_x => $x1,
            slot     => $input[0],
        );
    }
    else {

        # if you enter here there is no input or ...

        for ( my $i = 0 ; $i < $num_of_inputs ; $i++ ) {

            # ... you enter in this for loop

            my $slot_distance = $width / ( $num_of_inputs - 1 );
            my $center_y      = $y1;
            my $center_x      = $x1 + $slot_distance * $i;

            $self->add_input(
                center_y => $center_y,
                center_x => $center_x,
                slot     => $input[$i],
            );
        }
    }

    # draw outputs
    my @output         = $self->get_node->get_outputs;
    my $num_of_outputs = scalar @output;

    # if there is only one output, draw it in the north-est corner
    if ( $num_of_outputs == 1 ) {
        my $center_y = $y2;
        my $center_x = $x1;

        $self->add_output(
            center_y => $center_y,
            center_x => $center_x,
            slot     => $output[0],
        );

    }
    else {

        # if you enter here there is no output or ...

        for ( my $i = 0 ; $i < $num_of_outputs ; $i++ ) {

            # ... you enter in this for loop

            my $slot_distance = $width / ( $num_of_outputs - 1 );
            my $center_y      = $y2;
            my $center_x      = $x1 + $slot_distance * $i;

            $self->add_output(
                center_y => $center_y,
                center_x => $center_x,
                slot     => $input[$i],
            );
        }
    }

    $self->default_tk_bindings;

    return $self;
}

# return $input : PNI::GUI::Tk::Input
sub add_input {
    my $self = shift;

    my $slot = PNI::GUI::Tk::Input->new( @_, node => $self, )
      or return PNI::Error::unable_to_create_item;

    my $slot_tk_id = $slot->get_tk_id;
    $self->add_tk_id($slot_tk_id);
    $self->get('input')->{$slot_tk_id} = $slot;
}

# return $output : PNI::GUI::Tk::Output
sub add_output {
    my $self = shift;

    my $slot = PNI::GUI::Tk::Output->new( @_, node => $self, )
      or return PNI::Error::unable_to_create_item;

    my $slot_tk_id = $slot->get_tk_id;
    $self->add_tk_id($slot_tk_id);
    $self->get('output')->{$slot_tk_id} = $slot;
}

# return 1
sub add_tk_id {
    my $self = shift;
    my $tk_id = shift or return PNI::Error::missing_required_argument;
    push @{ $self->get('tk_ids') }, $tk_id;
}

# return 1
sub default_tk_bindings {
    my $self         = shift;
    my $border_tk_id = $self->get_border->get_tk_id;
    my $controller   = $self->get_controller;
    my $text_tk_id   = $self->get_text->get_tk_id;
    my $tk_canvas    = $self->get_tk_canvas;

    $tk_canvas->bind( $border_tk_id, '<B1-Motion>' => [ \&move, $self ] );
    $tk_canvas->bind( $text_tk_id,   '<B1-Motion>' => [ \&move, $self ] );
    $tk_canvas->bind( $text_tk_id,
        '<Double-Button-1>' =>
          [ sub { $controller->open_node_inspector($self) } ] );

    for my $slot ( $self->get_inputs, $self->get_outputs ) {
        $slot->default_tk_bindings;
    }
}

# return $border: PNI::GUI::Tk::Canvas::Rectangle
sub get_border { shift->get('border') }

# return $canvas: PNI::GUI::Tk::Canvas
sub get_canvas { shift->get_controller->get_canvas }

# return $controller: PNI::GUI::Tk::Controller
sub get_controller { shift->get('controller') }

sub get_input {
    my $self      = shift;
    my $slot_name = shift;

    for my $slot ( $self->get_inputs ) {
        next unless $slot->get_name eq $slot_name;
        return $slot;
    }
}

# return @input_tk_ids
sub get_input_tk_ids { keys %{ shift->get('input') } }

# return @inputs: PNI::GUI::Tk::Canvas::Rectangle
sub get_inputs { values %{ shift->get('input') } }

sub get_output {
    my $self      = shift;
    my $slot_name = shift;

    for my $slot ( $self->get_outputs ) {
        next unless $slot->get_name eq $slot_name;
        return $slot;
    }
}

# return @output_tk_ids
sub get_output_tk_ids { keys %{ shift->get('output') } }

# return @outputs: PNI::GUI::Tk::Canvas::Rectangle
sub get_outputs { values %{ shift->get('output') } }

# return $text: PNI::GUI::Tk::Canvas::Text

sub get_text { shift->get('text') }

# return $tk_canvas: Tk::Canvas
sub get_tk_canvas { shift->get_controller->get_tk_canvas }

# return @tk_ids
sub get_tk_ids { @{ shift->get('tk_ids') } }

# return 1
sub move {
    my $tk_canvas = shift;
    my $self      = shift;
    my $center_y  = $self->get_center_y;
    my $center_x  = $self->get_center_x;

    # TODO per evitare che esca dai bordi
    #my ( $x1, $y1, $x2, $y2 ) = $tk_canvas->coords( $self->id );

    my $y = $tk_canvas->XEvent->y;
    my $x = $tk_canvas->XEvent->x;

    my $dx = $x - $center_x;
    my $dy = $y - $center_y;

    # avoid going outside canvas borders
    # TODO can be improved
    return if $x + $dx < 1;
    return if $y + $dy < 1;

    $tk_canvas->move( $_, $dx, $dy ) for ( $self->get_tk_ids );

    $self->set_center_y($y);
    $self->set_center_x($x);

    for my $slot ( $self->get_inputs ) {
        my $center_y = $slot->get_center_y;
        my $center_x = $slot->get_center_x;

        $slot->set_center_y( $center_y + $dy );
        $slot->set_center_x( $center_x + $dx );

        if ( my $edge = $slot->get_edge ) {
            $edge->set_end_y( $center_y + $dy );
            $edge->set_end_x( $center_x + $dx );
        }
    }

    for my $slot ( $self->get_outputs ) {
        my $center_y = $slot->get_center_y;
        my $center_x = $slot->get_center_x;

        $slot->set_center_y( $center_y + $dy );
        $slot->set_center_x( $center_x + $dx );

        for my $edge ( $slot->get_edges ) {
            $edge->set_start_y( $center_y + $dy );
            $edge->set_start_x( $center_x + $dx );
        }
    }
}

1;
__END__

=head1 NAME

PNI::GUI::Tk::Node - 

=head1 METHODS

=head2 C<add_input>

=head2 C<add_output>

=head2 C<add_tk_id>

=head2 C<default_tk_bindings>

=head2 C<get_border>

=head2 C<get_canvas>

=head2 C<get_controller>

=head2 C<get_text>

=head2 C<get_tk_canvas>

=head2 C<move>

=head2 C<show_input_info>

=head2 C<show_output_info>

=cut

