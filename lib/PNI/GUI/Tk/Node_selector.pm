package PNI::GUI::Tk::Node_selector;
use strict;
use base 'PNI::Item';
use PNI;
use PNI::Error;
use PNI::GUI::Tk::Canvas::Window;
use Tk::MatchEntry;

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

    my $y = $arg->{y};
    $self->add( y => $y );

    my $x = $arg->{x};
    $self->add( x => $x );

    my $canvas    = $self->get_canvas;
    my $tk_canvas = $self->get_tk_canvas;

    my @nodes = PNI::node_list;

    my $entry;

    my $tk_matchentry = $tk_canvas->MatchEntry(
        -autoshrink   => 1,
        -autosort     => 1,
        -choices      => \@nodes,
        -command      => sub { return $self->choosen( \$entry ); },
        -entercmd     => sub { return $self->choosen( \$entry ); },
        -ignorecase   => 1,
        -maxheight    => 10,
        -textvariable => \$entry,
    );

    my $window = PNI::GUI::Tk::Canvas::Window->new(
        canvas => $canvas,
        window => $tk_matchentry,
        y      => $y,
        x      => $x
    ) or return PNI::Error::unable_to_create_item;
    $self->add( window => $window );

    ### new: __PACKAGE__ . ' id=' . $self->id
    return $self;
}

# return 1
sub choosen {
    my $self       = shift;
    my $entry_ref  = shift;
    my $entry      = ${$entry_ref};
    my $controller = $self->get_controller;
    my $y          = $self->get_y;
    my $x          = $self->get_x;

    for my $node_type (PNI::node_list) {

        # adjust case
        if ( lc $node_type eq lc $entry ) {

            # create choosen node
            return $controller->add_node(
                center_y => $y,
                center_x => $x,
                type     => $node_type,
            );
        }
    }

    # if $entry is not a node, create a Perldata::Scalar node
    return $controller->add_node(
        center_y => $y,
        center_x => $x,
        inputs   => { in => $entry },
        type     => 'Perldata::Scalar',
    );
}

# return $canvas: PNI::GUI::Tk::Canvas
sub get_canvas { return shift->get_controller->get_canvas; }

# return $controller: PNI::GUI::Tk::Controller

sub get_controller { return shift->get('controller') }

# return $tk_canvas: Tk::Canvas
sub get_tk_canvas { return shift->get_controller->get_tk_canvas; }

# return $window: PNI::GUI::Tk::Window

sub get_window { return shift->get('window') }

# return $y

sub get_y { return shift->get('y') }

# return $x

sub get_x { return shift->get('x') }

1;
__END__

=head1 NAME

PNI::GUI::Tk::Node_selector - 


=head1 METHODS

=head2 C<choosen>

=head2 C<get_canvas>

=head2 C<get_controller>

=head2 C<get_tk_canvas>

=head2 C<get_window>

=head2 C<get_y>

=head2 C<get_x>



=head1 AUTHOR

G. Casati , E<lt>fibo@cpan.orgE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2009-2011, Gianluca Casati

This program is free software, you can redistribute it and/or modify it
under the same terms of the Artistic License version 2.0 .

=cut
