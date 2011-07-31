package PNI::GUI::Tk::Scenario;
use strict;
use base 'PNI::GUI::Scenario';
use PNI::Error;
use PNI::GUI::Node;
use PNI::GUI::Tk::Edge;
use PNI::GUI::Tk::Node;

sub new {
    my $self = shift->SUPER::new(@_)
      or return PNI::Error::unable_to_create_item;
    my $arg = {@_};

    # controller is required
    my $controller = $arg->{controller}
      or return PNI::Error::missing_required_argument;

    # controller must be a PNI::GUI::Tk::Controller
    $controller->isa('PNI::GUI::Tk::Controller')
      or return PNI::Error::invalid_argument_type;

    $self->add( controller => $controller );

    return $self;
}

# return $edge : PNI::GUI::Tk::Edge
sub add_edge {
    my $self       = shift;
    my $controller = $self->get_controller;

    my $edge = PNI::GUI::Tk::Edge->new(
        controller => $controller,
        @_
    ) or return PNI::Error::unable_to_create_item;

    $self->get('edges')->{ $edge->id } = $edge;

    return $edge;
}

# return $node : PNI::GUI::Tk::Node
sub add_node {
    my $self       = shift;
    my $controller = $self->get_controller;
    my $scenario   = $self->get_scenario;

# TODO questo sarebe sbagliato, funziona solo perche' non si accavallano i nomi degli argomenti
#      infatti in add_edge mi dava problemi
    my $pni_node = $scenario->add_node(@_)
      or return PNI::Error::unable_to_create_item;

    my $node = PNI::GUI::Tk::Node->new(
        controller => $controller,
        node       => $pni_node,
        @_
    ) or return PNI::Error::unable_to_create_item;

    $self->get('nodes')->{ $node->id } = $node;

    return $node;
}

sub del_edge {
    my $self = shift;
    my $edge = shift
      or return PNI::Error::missing_required_argument;

    delete $self->get('edges')->{ $edge->id };

    return 1;
}

sub get_controller { shift->get('controller') }

# return @inputs: PNI::GUI::Tk::Input
sub get_inputs {
    my $self = shift;
    my @inputs;

    # TODO fai code cleaning con grep e map come fa Marcos
    for my $node ( $self->get_nodes ) {
        push @inputs, $node->get_inputs;
    }

    return @inputs;
}

# return @nodes : PNI::GUI::Tk::Node
sub get_nodes { values %{ shift->get('nodes') }; }

# return @outputs : PNI::GUI::Tk::Output
sub get_outputs {
    my $self = shift;
    my @outputs;

    # TODO fai code cleaning con grep e map come fa Marcos
    for my $node ( $self->get_nodes ) {
        push @outputs, $node->get_outputs;
    }

    return @outputs;
}

1;
__END__

=head1 NAME

PNI::GUI::Tk::Scenario - 

=head1 METHODS

=cut

