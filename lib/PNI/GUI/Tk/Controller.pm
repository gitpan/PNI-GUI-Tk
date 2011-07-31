package PNI::GUI::Tk::Controller;
use strict;
use base 'PNI::Item';
use PNI;
use PNI::Error;
use PNI::File;
use PNI::GUI::Tk::Canvas;
use PNI::GUI::Tk::Edge;
use PNI::GUI::Tk::Menu;
use PNI::GUI::Tk::Node;
use PNI::GUI::Tk::Node_inspector;
use PNI::GUI::Tk::Node_selector;
use PNI::GUI::Tk::Scenario;
use PNI::GUI::Tk::Window;

sub new {
    my $self  = shift->SUPER::new;
    my $arg   = {@_};

    # app is required
    my $app = $arg->{app}
      or return PNI::Error::missing_required_argument;

    # app must be a PNI::GUI::Tk::App
    $app->isa('PNI::GUI::Tk::App')
      or return PNI::Error::invalid_argument_type;

    $self->add( app => $app );

    # create window
    my $window = PNI::GUI::Tk::Window->new( controller => $self );
    $self->add( window => $window );

    # create menu;
    $self->add( menu => PNI::GUI::Tk::Menu->new( controller => $self ) );

    # create canvas
    $self->add(
        canvas => PNI::GUI::Tk::Canvas->new(
            controller => $self,
            tk_canvas  => $window->get_tk_main_window->Canvas(),
        )
    );

    # create scenario
    my $scenario = PNI::GUI::Tk::Scenario->new(
        controller => $self,
        file       => $arg->{file},

        # TODO by now i'm using the root scenario
        scenario => PNI::root->add_scenario,
    ) or return PNI::Error::unable_to_create_item;

    $self->add( scenario => $scenario );

    # set window title with .pni file path
    $self->set_window_title( $scenario->get_file->get_path );

    # finally, load the content of the .pni file
    $self->get_scenario->load_file;

    return $self;
}

# return 1
sub add_node {
    my $self = shift;
    $self->get_scenario->add_node(@_);
    return $self->del_node_selector;
}

# return 1
sub add_node_selector {
    my $self   = shift;
    my $canvas = $self->get_canvas;

    my $node_selector = PNI::GUI::Tk::Node_selector->new(@_);

    $self->add( node_selector => $node_selector );

    $canvas->opened_node_selector;

    return 1;
}

# return 1
sub close_window {
    my $self = shift;
    my $app  = $self->get_app;

    $self->get_tk_main_window->destroy;

    return $app->del_controller($self);
}

sub connect_edge_to_input {
    my $self = shift;
    my $edge = shift
      or return PNI::Error::missing_required_argument;
    my $input = shift
      or return PNI::Error::missing_required_argument;

    my $canvas = $self->get_canvas;

    if ( $input->is_connected ) {
        my $old_edge = $input->get_edge;
        $self->destroy_edge($old_edge);
    }

    $edge->set_target($input);
    $input->set_edge($edge);

    $self->default_tk_bindings;

    return 1;
}

sub connect_edge_to_output {
    my $self = shift;
    my $edge = shift
      or return PNI::Error::missing_required_argument;
    my $output = shift
      or return PNI::Error::missing_required_argument;

    my $canvas = $self->get_canvas;

    $edge->set_source($output);
    $output->add_edge($edge);

    return 1;
}

# return 1
sub connecting_edge {
    my $self   = shift;
    my $output = shift
      or return PNI::Error::missing_required_argument;

    my $y = $output->get_center_y;
    my $x = $output->get_center_x;

    my $edge = $self->get_scenario->add_edge(
        end_y   => $y,
        end_x   => $x,
        start_y => $y,
        start_x => $x,
    );
    $self->connect_edge_to_output( $edge, $output );
    $self->get_canvas->connecting_edge_tk_bindings($edge);

    return 1;
}

sub default_tk_bindings {
    my $self     = shift;
    my $canvas   = $self->get_canvas;
    my $scenario = $self->get_scenario;

    $canvas->default_tk_bindings;

    for my $slot ( $scenario->get_inputs, $scenario->get_outputs ) {
        $slot->default_tk_bindings;
    }

    return 1;
}

# return 1
sub del_node_selector {
    my $self          = shift;
    my $canvas        = $self->get_canvas;
    my $node_selector = $self->get_node_selector;

    my $tk_canvas = $self->get_tk_canvas;
    my $window    = $node_selector->get_window;
    my $tk_id     = $window->get_tk_id;
    $tk_canvas->delete($tk_id);

    $self->del('node_selector');

    $canvas->default_tk_bindings;

    return 1;
}

sub destroy_edge {
    my $self = shift;
    my $edge = shift
      or return PNI::Error::missing_required_argument;

    my $source = $edge->get_source;
    my $target = $edge->get_target;

    defined $source and $source->del_edge($edge);
    defined $target and $target->del_edge($edge);

    $self->get_scenario->del_edge($edge);

    $edge->get_line->delete;

    $self->default_tk_bindings;
}

sub get_app { shift->get('app') }

sub get_canvas { shift->get('canvas') }

sub get_node_selector { shift->get('node_selector') }

sub get_tk_canvas { shift->get_canvas->get_tk_canvas }

sub get_tk_main_window { shift->get_window->get_tk_main_window }

sub get_scenario { shift->get('scenario') }

sub get_window { shift->get('window') }

sub open_node_inspector {
    my $self = shift;
    my $node = shift;

    return PNI::GUI::Tk::Node_inspector->new(
        controller => $self,
        node       => $node,
    );
}

sub open_pni_file {
    my $self = shift;

    my $path =
      $self->get_tk_main_window->getOpenFile( -title => 'Open .pni file', )
      or return;

    $self->get_app->add_controller( file => PNI::File->new( path => $path ) );
}

sub save_pni_file {
    my $self     = shift;
    my $scenario = $self->get_scenario;
    return $scenario->save_file;
}

sub save_as_pni_file {
    my $self     = shift;
    my $scenario = $self->get_scenario;

    my $path =
      $self->get_tk_main_window->getSaveFile( -title => 'Save as .pni file', );

    $scenario->set_file( PNI::File->new( path => $path ) );
    $scenario->save_file;
}

sub select_edge {

    #print @_, "\n";
}

sub set_window_title {
    my $self  = shift;
    my $title = shift
      or return PNI::Error::missing_required_argument;

    my $window = $self->get_window;
    return $window->set_title($title);
}
1;
__END__

=head1 NAME

PNI::GUI::Tk::Controller - 

=head1 METHODS

=head2 C<close_window>

    $self->close_window;

Close Tk window and delete controller.

=head2 C<save_as_pni_file>

    $self->save_as_pni_file;

Opens a Tk getSaveFile window to let the user choose a path, and saves scenario content.

=head2 C<save_pni_file>

    $self->save_pni_file;

Save scenario content in its .pni file.

=cut

