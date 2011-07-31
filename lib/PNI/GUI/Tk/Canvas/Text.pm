package PNI::GUI::Tk::Canvas::Text;
use strict;
use warnings;
use base 'PNI::GUI::Tk::Canvas::Item';
use PNI;
use PNI::Error;

sub new {
    my $class = shift;
    my $arg   = {@_};
    my $self  = $class->SUPER::new(@_)
      or return PNI::Error::unable_to_create_item;

    my $y = $arg->{y};
    $self->add( y => $y );

    my $x = $arg->{x};
    $self->add( x => $x );

    my $text = $arg->{text};
    $self->add( text => $text );

    my $tk_canvas = $self->get_tk_canvas;

    my $node = PNI::node 'Tk::Canvas::Text';
    $node->get_input('canvas')->set_data($tk_canvas);
    $node->get_input('text')->set_data($text);
    $node->get_input('y')->set_data($y);
    $node->get_input('x')->set_data($x);

    $self->add( node => $node );

    $node->task;

    my $tk_id = $node->get_output('tk_id')->get_data;
    $self->set( tk_id => $tk_id );

    return $self;
}

sub get_node { shift->get('node') }

1;
__END__

=head1 NAME

PNI::GUI::Tk::Canvas::Text - Tk::Canvas text item

=head1 METHODS

=head2 C<get_node>

=cut
