package PNI::GUI::Tk::Canvas;
use strict;
use warnings;
our $VERSION = '0.1';
use base 'PNI::GUI::Tk::Item';
use PNI;
use PNI::Error;
use PNI::Scenario::Node;
use Tk::Tree;

sub new {
    my $class = shift;
    my $arg = {@_} or return;

    # window arg is required and it must be a PNI::GUI::Tk::Window
    my $window = $arg->{window} or return PNI::Error::missing_required_argument;
    $window->isa('PNI::GUI::Tk::Window')
      or return PNI::Error::invalid_argument_type;

    my $gui      = $window->get_gui;
    my $scenario = $window->get_scenario;

    my $tk = $window->tk->Canvas();
    $tk->isa('Tk::Canvas');

    my $self = $class->SUPER::new(
        gui      => $gui,
        scenario => $scenario,
        'tk'     => $tk
    );

    # default configuration for my canvas
    $tk->configure(
        -confine          => 0,
        -height           => 400,
        -width            => 600,
        -scrollregion     => [ 0, 0, 1000, 1000 ],
        -xscrollincrement => 1,
        -background       => 'white'
    );
    $tk->pack( -expand => 1, -fill => 'both' );
    $tk->CanvasBind( '<Double-Button-1>' => [ \&_on_double_click, $self ] );

    $tk->configure( -cursor => 'plus' );

    return $self;
}

sub _on_double_click {
    my $tk   = shift;
    my $self = shift;
    my $x    = $tk->XEvent->x;
    my $y    = $tk->XEvent->y;

    if ( $tk->find( 'withtag', 'current' ) ) {

        # do nothing when double clicking an item
    }
    else {

        # disable default double click callout
        # so there is only one selector open
        $tk->CanvasBind( '<Double-Button-1>' => undef );

        # and create selector
        $self->_open_selector( $x, $y );
    }

    return;
}

sub _open_selector {
    my $self = shift;
    my $x    = shift;
    my $y    = shift;
    my $tk   = $self->tk;

    my $height = 20;

    my $tk_tree = $tk->Tree(
        -height => $height,
        -width  => 30
    );

    my $nodes = PNI::NODES;

    for my $node_category ( keys %{$nodes} ) {
        $tk_tree->add(
            $node_category,
            -text  => $node_category,
            -state => 'disabled'
        );

        for my $node ( @{ $nodes->{$node_category} } ) {
            $tk_tree->add(
                "$node_category.$node",
                -text  => $node,
                -state => 'normal'
            );

        }
    }

    my $tree_tk_id =
      $tk->createWindow( $x, $y + $height * 10 / 2, -window => $tk_tree );

    $tk_tree->configure(
        -command => [ \&add_node, $self, $x, $y, $tk_tree, $tree_tk_id ] );

    # clicking the canvas destroys node selector
    $tk->CanvasBind(
        '<ButtonPress-1>' => [
            sub {
                $tk->delete($tree_tk_id);

                # restore default double click callout
                $tk->CanvasBind(
                    '<Double-Button-1>' => [ \&_on_double_click, $self ] );

                return;
              }
        ]
    );

    return;
}

sub add_node {
    my $self       = shift;
    my $x          = shift;
    my $y          = shift;
    my $tk_tree    = shift;
    my $tree_tk_id = shift;
    my $entry_path = shift;    # last parameter

    my $tk = $self->tk;

    # delete selector widget
    $tk_tree->destroy;
    $tk->delete($tree_tk_id);

    # restore default double click callout
    $tk->CanvasBind( '<Double-Button-1>' => [ \&_on_double_click, $self ] );

    my $node_type = $entry_path;
    $node_type =~ s/\./::/g;

    $self->get_scenario->add_node(
        center    => [ $x, $y ],
        node_type => $node_type
    ) or return;

    return 1;
}

1;
