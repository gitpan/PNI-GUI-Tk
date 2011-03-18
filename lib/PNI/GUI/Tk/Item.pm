package PNI::GUI::Tk::Item;
use strict;
use warnings;
our $VERSION = '0.11';
use base 'PNI::Item';
use PNI::Error;

sub new {
    my $class = shift;
    my $arg   = {@_};

    # arg scenario is required and it should be a PNI::Scenario
    my $scenario = $arg->{scenario}
      or return PNI::Error::missing_required_argument;
    $scenario->isa('PNI::GUI::Tk::Scenario')
      or return PNI::Error::invalid_argument_type;

    # tk arg is required and it should be a Tk::*
    my $tk = $arg->{tk} or return PNI::Error::missing_required_argument;

    my $gui = $arg->{gui} or return PNI::Error::missing_required_argument;

    my $self = $class->SUPER::new();
    $self->add( gui      => $gui );
    $self->add( scenario => $scenario );
    $self->add( tk       => $tk );
    return $self;
}

sub get_gui { return shift->get('gui'); }

sub get_scenario { return shift->get('scenario'); }

# this accessor doesn't follow the *** get set add del *** convention
# since it is more elegant call, for instance
# $canvas->tk or $menu->tk
sub tk { return shift->get('tk'); }

1;

