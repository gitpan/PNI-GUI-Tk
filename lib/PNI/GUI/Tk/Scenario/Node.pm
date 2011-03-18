package PNI::GUI::Tk::Scenario::Node;
use strict;
use warnings;
our $VERSION = '0.11';
use base 'PNI::Scenario::Node';

my $slot_half_width = 8;
my $slot_fill       = 'gray';
my $slot_activefill = 'black';

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_) or return;

    my $scenario = $self->get_scenario;
    my $tk = $scenario->get_canvas->tk or return;

    $self->add( input           => {} );
    $self->add( input_links     => [] );
    $self->add( output          => {} );
    $self->add( output_links    => [] );
    $self->add( slot_half_width => $slot_half_width );
    my $tk_tag = 'Node' . $self->id;
    $self->add( tk_tag => $tk_tag );

    my $center_x = $self->get_center_x;
    my $center_y = $self->get_center_y;
    my $width    = $self->get_width;
    my $height   = $self->get_height;

    my $border_tk_id = $tk->createRectangle(
        $center_x - $width / 2,
        $center_y + $height / 2,
        $center_x + $width / 2,
        $center_y - $height / 2
    );
    $self->add( border_tk_id => $border_tk_id );

    my $label_tk_id =
      $tk->createText( $center_x, $center_y, -text => $self->get_label );
    $self->add( label_tk_id => $label_tk_id );

    # draw inputs
    my @inputs = $self->get_node->get_inputs;
    my $num_input_minus_one = $#inputs || 1;

    for ( my $i = 0 ; $i <= $#inputs ; $i++ ) {
        my $input = $inputs[$i];
        my $input_center_x =
          $center_x - $width / 2 + $i * $width / $num_input_minus_one;
        my $input_center_y = $center_y - $height / 2;

        my $input_tk_id = $tk->createRectangle(
            $input_center_x - $slot_half_width / 2,
            $input_center_y + $slot_half_width / 2,
            $input_center_x + $slot_half_width / 2,
            $input_center_y - $slot_half_width / 2,
            -fill       => $slot_fill,
            -activefill => $slot_activefill
        );

        $self->add_input( $input_tk_id => $input );

        ##### TODO prova ad usare questo per ottimizzare la ricerca nel canvas
        #$tk->addtag( 'input', 'withtag', $input_tk_id );

        # make sure slot is above label and border
        $tk->raise( $input_tk_id, $_ )
          for ( $self->get_label_tk_id, $self->get_border_tk_id );

        # default callout bindings
        $tk->bind( $input_tk_id,
            '<Enter>' => [ \&_on_input_enter, $self, $input_tk_id ] );
        $tk->bind( $input_tk_id,
            '<Double-Button-1>' => [ \&_open_input_editor, $self, $input_tk_id ]
        );

        $tk->bind( $input_tk_id, '<Leave>' => undef );
    }

    # draw outputs
    my @outputs = $self->get_node->get_outputs;
    my $num_output_minus_one = $#outputs || 1;

    for ( my $i = 0 ; $i <= $#outputs ; $i++ ) {
        my $output = $outputs[$i];
        my $output_center_x =
          $center_x - $width / 2 + $i * $width / $num_output_minus_one;
        my $output_center_y = $center_y + $height / 2;

        my $output_tk_id = $tk->createRectangle(
            $output_center_x - $slot_half_width / 2,
            $output_center_y + $slot_half_width / 2,
            $output_center_x + $slot_half_width / 2,
            $output_center_y - $slot_half_width / 2,
            -fill       => $slot_fill,
            -activefill => $slot_activefill
        );

        $self->add_output( $output_tk_id => $output );

        # make sure slot is above label and border
        $tk->raise( $output_tk_id, $_ )
          for ( $self->get_label_tk_id, $self->get_border_tk_id );

        # default callout bindings
        $tk->bind( $output_tk_id,
            '<Enter>' => [ \&_on_output_enter, $self, $output_tk_id ] );

        $tk->bind( $output_tk_id,
            '<ButtonPress-1>' => [ \&_new_link, $self, $output_tk_id ] );

        $tk->bind( $output_tk_id, '<Leave>' => undef );
    }

    for my $tk_id ( $self->get_tk_ids ) {

        # add tk_tag to all items
        $tk->addtag( $tk_tag, 'withtag', $tk_id );
    }

    # callout bindings
    $tk->bind( $border_tk_id, '<B1-Motion>' => [ \&_on_move, $self ] );
    $tk->bind( $label_tk_id,  '<B1-Motion>' => [ \&_on_move, $self ] );

    return $self;
}

sub _close_input_editor {

    my $entry              = shift;
    my $self               = shift;
    my $tk                 = shift;
    my $input_editor_tk_id = shift;
    my $input              = shift;

    $input->set_data( $entry->get );
    $tk->delete($input_editor_tk_id);

    return;
}

sub _new_link {
    my $tk           = shift;
    my $self         = shift;
    my $output_tk_id = shift;

    my ( $x1, $y1, $x2, $y2 ) = $tk->coords($output_tk_id);
    my $start_x = ( $x1 + $x2 ) / 2;
    my $start_y = ( $y1 + $y2 ) / 2;
    my $end_x   = $start_x;
    my $end_y   = $start_y;

    my $line_tk_id =
      $tk->createLine( $start_x, $start_y, $end_x, $end_y, -arrow => 'none' );

    $tk->CanvasBind(
        '<B1-Motion>' => [
            sub {
                my $tk = shift;
                $end_x = $tk->XEvent->x;
                $end_y = $tk->XEvent->y;
                $tk->coords( $line_tk_id, $start_x, $start_y, $end_x, $end_y );
                return;
              }
        ]
    );

    $tk->CanvasBind(
        '<ButtonRelease-1>' => [
            sub {
                my $tk   = shift;
                my $self = shift;

                my $closest_tk_id =
                  ( $tk->find( 'closest', $tk->XEvent->x, $tk->XEvent->y ) )[0];

                my $input;
                my $node =
                  $self->get_scenario->get_node_of_input_tk_id($closest_tk_id);
                if ( defined $node ) {
                    $input = $node->get_input_by_tk_id($closest_tk_id);

                }

                # if it is an input create a link ...
                if ( defined $input ) {

                    my $input_tk_id = $closest_tk_id;

                    my $output = $self->get_output_by_tk_id($output_tk_id);
                    $self->get_scenario->add_link(
                        input_tk_id  => $input_tk_id,
                        line_tk_id   => $line_tk_id,
                        output_tk_id => $output_tk_id,
                        source       => $output,
                        target       => $input,
                        source_node  => $self,
                        target_node  => $node
                    );

                    # make sure slots are above line
                    $tk->raise( $input_tk_id,  $line_tk_id );
                    $tk->raise( $output_tk_id, $line_tk_id );
                }
                else {

                    # ... otherwise destroy the line
                    $tk->delete($line_tk_id);
                }

                # reset callouts
                $tk->CanvasBind( '<ButtonRelease-1>' => undef );
                $tk->CanvasBind( '<B1-Motion>'       => undef );

                return;
            },
            $self
        ]
    );

    return 1;
}

sub _on_input_enter {
    my $tk          = shift;
    my $self        = shift;
    my $input_tk_id = shift or return;
    my $input       = $self->get_input_by_tk_id($input_tk_id);
    my $name        = $input->get_name;
    my $data        = $input->get_data;
    my $text;
    if ( defined $data ) {
        $text = $name . ' | ' . $data;
    }
    else {
        $text = $name . ' | ';
    }
    my $x = $tk->XEvent->x;
    my $y = $tk->XEvent->y;

    my $info_label_tk_id = $tk->createText( $x, $y - 20, -text => $text );

    $tk->bind( $input_tk_id,
        '<Leave>' => [ \&_on_slot_leave, $input_tk_id, $info_label_tk_id ] );
    return;
}

sub _on_output_enter {
    my $tk           = shift;
    my $self         = shift;
    my $output_tk_id = shift or return;
    my $output       = $self->get_output_by_tk_id($output_tk_id);
    my $name         = $output->get_name;
    my $data         = $output->get_data;
    my $text;
    if ( defined $data ) {
        $text = $name . ' | ' . $data;
    }
    else {
        $text = $name . ' | ';
    }
    my $x = $tk->XEvent->x;
    my $y = $tk->XEvent->y;

    my $info_label_tk_id = $tk->createText( $x, $y + 20, -text => $text );

    $tk->bind( $output_tk_id,
        '<Leave>' => [ \&_on_slot_leave, $output_tk_id, $info_label_tk_id ] );
    return;
}

sub _on_move {
    my $tk   = shift;
    my $self = shift;

    my $center_x = $self->get_center_x;
    my $center_y = $self->get_center_y;
    my $tk_tag   = $self->get_tk_tag;

    my $event_x = $tk->XEvent->x;
    my $event_y = $tk->XEvent->y;
    #### TODO non mi sembra corretto, dovrei prendere le coordinate
    # di un solo tk_id, quello del bordo , vabbe per ora non sembra un problema
    my ( $x1, $y1, $x2, $y2 ) = $tk->coords($tk_tag);

    my $dx = $event_x - $center_x;
    my $dy = $event_y - $center_y;

    # prevent node exit from canvas left and up borders
    return if $x1 + $dx < 1;
    return if $y1 + $dy < 1;

    for my $tk_id ( $tk->find( 'withtag', $tk_tag ) ) {
        $tk->move( $tk_id, $dx, $dy );
    }

    # move slots
    for my $input_link ( $self->get_input_links ) {
        my $input_tk_id = $input_link->get_input_tk_id;
        my $line_tk_id  = $input_link->get_line_tk_id;
        my ( $x1, $y1, $x2, $y2 ) = $tk->coords($line_tk_id);
        $tk->coords( $line_tk_id, $x1, $y1, $x2 + $dx, $y2 + $dy );
    }

    for my $output_link ( $self->get_output_links ) {
        my $output_tk_id = $output_link->get_output_tk_id;
        my $line_tk_id   = $output_link->get_line_tk_id;
        my ( $x1, $y1, $x2, $y2 ) = $tk->coords($line_tk_id);
        $tk->coords( $line_tk_id, $x1 + $dx, $y1 + $dy, $x2, $y2 );
    }

    # update node center
    $self->set_center( [ $event_x, $event_y ] );

    return 1;
}

sub _on_slot_leave {
    my $tk               = shift;
    my $slot_tk_id       = shift;
    my $info_label_tk_id = shift;
    $tk->delete($info_label_tk_id);
    $tk->bind( $slot_tk_id, '<Leave>' => undef );
    return;
}

sub _open_input_editor {
    my $tk          = shift;
    my $self        = shift;
    my $input_tk_id = shift;

    my $center_x        = $self->get_center_x;
    my $center_y        = $self->get_center_y;
    my $input           = $self->get_input_by_tk_id($input_tk_id);
    my $input_data      = $input->get_data;
    my $input_name      = $input->get_name;
    my $node            = $self->get_node;
    my $slot_half_width = $self->get_slot_half_width;
    my $tk_tag          = $self->get_tk_tag;

    my $frame = $tk->Frame( -height => 60, -width => 30 );

    my $label = $frame->Label( -text => $input_name, -width => 10 );
    $label->pack( -side => 'left', -fill => 'none' );

    my $entry = $frame->Entry( -width => 10 );
    $entry->insert( 0, $input_data );
    $entry->pack( -side => 'right' );

    my $input_editor_tk_id = $tk->createWindow(
        $center_x,
        $center_y - ( $slot_half_width * 3 ),
        -window => $frame,
        -tags   => [$tk_tag]
    );

    # let input_editor move with its node
    $tk->bind( $input_editor_tk_id, '<B1-Motion>' => [ \&_on_move, $self ] );

    # return key enters data
    $entry->bind( '<Return>' =>
          [ \&_close_input_editor, $self, $tk, $input_editor_tk_id, $input ] );

    # clicking the canvas destroys input editor
    $tk->CanvasBind(
        '<ButtonPress-1>' => [ sub { $tk->delete($input_editor_tk_id); } ] );

    return;
}

sub add_input {
    my $self        = shift;
    my $input_tk_id = shift or return;
    my $input       = shift or return;
    $self->get('input')->{$input_tk_id} = $input;

    # let know scenario that this input_tk_id belongs to this node
    $self->get_scenario->set_node_of_input_tk_id( $input_tk_id => $self );
    return 1;
}

sub add_input_link {
    my $self = shift;
    my $link = shift or return;
    push @{ $self->get('input_links') }, $link;
    return 1;
}

sub add_output {
    my $self         = shift;
    my $output_tk_id = shift or return;
    my $output       = shift or return PNI::Error::missing_required_argument;
    $self->get('output')->{$output_tk_id} = $output;
    return 1;
}

sub add_output_link {
    my $self = shift;
    my $link = shift or return PNI::Error::missing_required_argument;
    push @{ $self->get('output_links') }, $link;
    return 1;
}

sub get_border_tk_id { return shift->get('border_tk_id'); }

sub get_input_by_tk_id {
    my $self        = shift;
    my $input_tk_id = shift or return;
    my $input       = $self->get('input')->{$input_tk_id};
    return $self->get('input')->{$input_tk_id};
}

sub get_input_links { return @{ shift->get('input_links') }; }

sub get_input_tk_ids { return keys %{ shift->get('input') }; }

sub get_label_tk_id { return shift->get('label_tk_id'); }

sub get_output_by_tk_id {
    my $self = shift;
    my $output_tk_id = shift or return;
    return $self->get('output')->{$output_tk_id};
}

sub get_output_links { return @{ shift->get('output_links') }; }

sub get_output_tk_ids { return keys %{ shift->get('output') }; }

sub get_tk_ids {
    my $self = shift;
    my @tk_ids;
    push @tk_ids, $self->get_border_tk_id;
    push @tk_ids, $self->get_input_tk_ids;
    push @tk_ids, $self->get_label_tk_id;
    push @tk_ids, $self->get_output_tk_ids;
    return @tk_ids;
}

sub get_slot_half_width { return shift->get('slot_half_width'); }

sub get_tk_tag { return shift->get('tk_tag'); }

1;
