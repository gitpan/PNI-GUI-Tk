package PNI::GUI::Tk::Scenario::Link;
use strict;
use warnings;
our $VERSION = '0.11';
use base 'PNI::Scenario::Link';
use PNI::Error;

sub new {
    my $class = shift;
    my $arg   = {@_};

    # arg input_tk_id is required
    my $input_tk_id = $arg->{input_tk_id}
      or return PNI::Error::missing_required_argument;

    # arg line_tk_id is required
    my $line_tk_id = $arg->{line_tk_id}
      or return PNI::Error::missing_required_argument;

    # arg output_tk_id is required
    my $output_tk_id = $arg->{output_tk_id}
      or return PNI::Error::missing_required_argument;

    my $self = $class->SUPER::new(@_)
      or return PNI::Error::unable_to_create_item;
    $self->add( input_tk_id  => $input_tk_id );
    $self->add( line_tk_id   => $line_tk_id );
    $self->add( output_tk_id => $output_tk_id );

    return $self;
}

sub get_input_tk_id { return shift->get('input_tk_id'); }

sub get_line_tk_id { return shift->get('line_tk_id'); }

sub get_output_tk_id { return shift->get('output_tk_id'); }

1;
