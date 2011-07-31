package PNI::GUI::Tk::Canvas;
use strict;
use base 'PNI::Item';

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

    # $tk_canvas is required
    my $tk_canvas = $arg->{tk_canvas}
      or return PNI::Error::missing_required_argument;

    # $tk_canvas must be a Tk::Canvas
    $tk_canvas->isa('Tk::Canvas') or return PNI::Error::invalid_argument_type;

    $self->add( tk_canvas => $tk_canvas );

    $tk_canvas->pack( -expand => 1, -fill => 'both' );

    $self->default_tk_bindings;
    $self->default_tk_configure;

    ### new: __PACKAGE__ . ' id=' . $self->id
    return $self;
}

sub connect_or_destroy_edge {
    my $tk_canvas = shift;
    my $self      = shift;
    my $edge      = shift;

    my $controller = $self->get_controller;
    my $closest_input;
    my $closest_distance;

    my $y = $tk_canvas->XEvent->y;
    my $x = $tk_canvas->XEvent->x;

    for my $input ( $controller->get_scenario->get_inputs ) {

        # if it is the first input, by now it is the closest
        if ( not defined $closest_input ) {
            $closest_input = $input;
        }

        my $y__closest_y = $y - $closest_input->get_center_y;
        my $x__closest_x = $x - $closest_input->get_center_x;

        my $y__center_y = $y - $input->get_center_y;
        my $x__center_x = $x - $input->get_center_x;

        my $distance =
          sqrt( $y__center_y * $y__center_y + $x__center_x * $x__center_x );
        $closest_distance =
          sqrt( $y__closest_y * $y__closest_y + $x__closest_x * $x__closest_x );

        if ( $distance < $closest_distance ) {
            $closest_input    = $input;
            $closest_distance = $distance;
        }
    }

    if ( $closest_distance > 10 ) {
        return $controller->destroy_edge($edge);
    }
    else {
        return $controller->connect_edge_to_input( $edge, $closest_input );
    }
}

sub connecting_edge_tk_bindings {
    my $self      = shift;
    my $edge      = shift;
    my $tk_canvas = $self->get_tk_canvas;

    $tk_canvas->CanvasBind(
        '<B1-Motion>' => sub {

            # move unconnected edge
            $edge->set_end_y( $tk_canvas->XEvent->y );
            $edge->set_end_x( $tk_canvas->XEvent->x );
        }
    );
    $tk_canvas->CanvasBind( '<ButtonPress-1>' => undef );
    $tk_canvas->CanvasBind(
        '<ButtonRelease-1>' => [ \&connect_or_destroy_edge, $self, $edge ] );
    $tk_canvas->CanvasBind( '<Double-Button-1>' => undef );

    return 1;
}

# return 1
sub default_tk_bindings {
    my $self      = shift;
    my $tk_canvas = $self->get_tk_canvas;

    $tk_canvas->CanvasBind( '<B1-Motion>'       => undef );
    $tk_canvas->CanvasBind( '<ButtonPress-1>'   => undef );
    $tk_canvas->CanvasBind( '<ButtonRelease-1>' => undef );
    $tk_canvas->CanvasBind( '<Double-Button-1>' => [ \&double_click, $self ] );

    return 1;
}

# return 1 ??
sub default_tk_configure {
    return shift->get_tk_canvas->configure(
        -confine          => 0,
        -height           => 400,
        -width            => 600,
        -scrollregion     => [ 0, 0, 1000, 1000 ],
        -xscrollincrement => 1,
        -background       => 'white'
    );
}

# return 1
sub double_click {
    my $tk_canvas  = shift;
    my $self       = shift;
    my $controller = $self->get_controller;

    my $x = $tk_canvas->XEvent->x;
    my $y = $tk_canvas->XEvent->y;

    if ( $tk_canvas->find( 'withtag', 'current' ) ) {

        # do nothing when double clicking an item
    }
    else {

        # disable default double click callout
        # so there is only one selector open
        $tk_canvas->CanvasBind( '<Double-Button-1>' => undef );

        # and create node selector
        $controller->add_node_selector(
            controller => $controller,
            x          => $x,
            y          => $y,
        );
    }
    return 1;
}

sub get_controller { return shift->get('controller') }

sub get_tk_canvas { return shift->get('tk_canvas') }

sub opened_node_selector {
    my $self       = shift;
    my $controller = $self->get_controller;
    my $tk_canvas  = $self->get_tk_canvas;

    # clicking the canvas destroys node selector
    $tk_canvas->CanvasBind(
        '<ButtonPress-1>' => [ sub { $controller->del_node_selector } ] );

    return 1;
}

1;
__END__

=head1 NAME

PNI::GUI::Tk::Canvas - 



=head1 AUTHOR

G. Casati , E<lt>fibo@cpan.orgE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2009-2011, Gianluca Casati

This program is free software, you can redistribute it and/or modify it
under the same terms of the Artistic License version 2.0 .

=cut
