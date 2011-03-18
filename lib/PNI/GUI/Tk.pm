package PNI::GUI::Tk;
use strict;
use warnings;
our $VERSION = '0.11';
use base 'PNI::GUI';
use PNI::Error;
use PNI::GUI::Tk::Scenario;
use PNI::GUI::Tk::Window;
use Tk;    # it is enough say "use Tk" just once

sub new {
    my $class = shift;

    my $self = $class->SUPER::new or return;
    $self->add( 'window' => {} );

    # create the first window
    $self->add_window;

    return $self;
}

sub add_window {
    my $self     = shift;
    my $scenario = PNI::GUI::Tk::Scenario->new;
    my $window   = PNI::GUI::Tk::Window->new(
        gui      => $self,
        scenario => $scenario
    ) or return PNI::Error::unable_to_create_item;

    $self->get('window')->{ $window->id } = $window;

    return $window;
}

sub del_window {
    my $self = shift;
    my $window = shift or return PNI::Error::missing_required_argument;

	my $window_id = $window->id;

	### TODO per ora funza poi aggiusta bene
	$window->close;
    delete $self->get('window')->{ $window->id };
    undef $window;

	# if it is the last window exit process
	if( keys %{$self->get('window')}){

	}
	else{
		Tk::exit();
	}

    return 1;
}

1;

=head1 NAME

PNI::GUI::Tk - Perl Node Interface GUI, implemented with Tk

=cut

