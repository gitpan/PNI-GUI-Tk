package PNI::GUI::Tk::Scenario;
use strict;
use warnings;
our $VERSION = '0.11';
use base 'PNI::Scenario';
use PNI::GUI::Tk::Scenario::Link;
use PNI::GUI::Tk::Scenario::Node;
use PNI::Error;
use PNI::Link;
use PNI::Node;

sub new {
    my $class = shift;

    my $self = $class->SUPER::new() or return;

    # window attribute it is not passed at creation
    # it is filled by PNI::GUI::Tk::Window constructor
    $self->add('window');

    # store a relation between nodes an its input_tk_ids
    $self->add( node_of_input_tk_id => {} );

    return $self;
}

sub add_link {
    my $self         = shift;
    my $arg          = {@_};
    my $source       = $arg->{source};
    my $target       = $arg->{target};
    my $input_tk_id  = $arg->{input_tk_id};
    my $line_tk_id   = $arg->{line_tk_id};
    my $output_tk_id = $arg->{output_tk_id};
    my $source_node  = $arg->{source_node} or return;
    my $target_node  = $arg->{target_node} or return;

    my $tk = $self->get_canvas->tk;

    my ( $x11, $y11, $x12, $y12 ) = $tk->coords($output_tk_id);
    my $start_x = ( $x11 + $x12 ) / 2;
    my $start_y = ( $y11 + $y12 ) / 2;
    my $start   = [ $start_x, $start_y ];

    my ( $x21, $y21, $x22, $y22 ) = $tk->coords($input_tk_id);
    my $end_x = ( $x21 + $x22 ) / 2;
    my $end_y = ( $y21 + $y22 ) / 2;
    my $end   = [ $end_x, $end_y ];

    my $pni_link = PNI::Link->new( source => $source, target => $target )
      or return PNI::Error::unable_to_create_item;

    my $link = PNI::GUI::Tk::Scenario::Link->new(
        input_tk_id  => $input_tk_id,
        line_tk_id   => $line_tk_id,
        output_tk_id => $output_tk_id,
        link         => $pni_link,
        start        => [ $start_x, $start_y ],
        end          => [ $end_x, $end_y ],
        scenario     => $self
    ) or return PNI::Error::unable_to_create_item;

    # attach link to nodes
    $source_node->add_output_link($link);
    $target_node->add_input_link($link);

    return 1;
}

sub add_node {
    my $self      = shift;
    my $arg       = {@_};
    my $node_type = $arg->{node_type}
      or return PNI::Error::missing_required_argument;

    my $node = PNI::NODE $node_type;

    return PNI::GUI::Tk::Scenario::Node->new(
        @_,
        node     => $node,
        scenario => $self
    );
}

sub get_canvas {
    my $self = shift;

    # if window was not initialized there will be no canvas
    my $window = $self->get_window or return;
    return $window->get('canvas');
}

sub get_node_of_input_tk_id {
    my $self        = shift;
    my $input_tk_id = shift;
    return $self->get('node_of_input_tk_id')->{$input_tk_id};
}

sub get_window { return shift->get('window'); }

sub set_node_of_input_tk_id {
    my $self        = shift;
    my $input_tk_id = shift or return;
    my $node        = shift or return;
    $self->get('node_of_input_tk_id')->{$input_tk_id} = $node;
    return 1;
}

1;

