package PNI::GUI::Tk::Menu;
use strict;
use warnings;
our $VERSION = '0.11';
use base 'PNI::GUI::Tk::Item';
use Tk::Dialog;

sub new {
    my $class = shift;
    my $arg   = {@_};

    # window arg is required and it must be a PNI::GUI::Tk::Window
    my $window = $arg->{window} or return;
    $window->isa('PNI::GUI::Tk::Window') or return;

    my $gui      = $window->get_gui;
    my $scenario = $window->get_scenario;

    my $tk_menu = $window->tk->Menu( -type => 'menubar' );
    $tk_menu->isa('Tk::Menu') or return;

    my $self = $class->SUPER::new(
        gui      => $gui,
        scenario => $scenario,
        tk       => $tk_menu
    );
    $self->add( 'window' => $window );

    # attach menu to its window
    $window->tk->configure( -menu => $self->tk );

    # populate menu entries
    $self->tk->Cascade(
        -label     => 'Scenario',
        -tearoff   => 1,
        -menuitems => [
            [
                Button   => 'New',
                -command => [
                    sub {
                        $self->get_gui->add_window;
                        return;
                      }
                ]
            ],
            [
                Button   => 'Close',
                -command => [
                    sub {
                        $self->get_gui->del_window( $self->get_window );
                        return;
                      }
                ]
            ],
            [
                Button   => 'Exit',
                -command => [ sub { Tk::exit(); } ]
            ]
        ]
    );
    $self->tk->Cascade(
        -label     => '~Help',
        -tearoff   => 0,
        -menuitems => [
            [
                Button   => 'About',
                -command => [
                    sub {
                        print "ue";
                        my $info_window = $self->get_window->tk->Toplevel(-title=>'Perl Node Interface');
						$info_window->geometry('300x150+100+100');
                        $info_window->Label( -text => 'PNI version: 0.11' )->pack;
                        $info_window->Label( -text => 'PNI::GUI::Tk version 0.11' )->pack;
                        $info_window->Label( -text => 'for more info point your browser to' )->pack;
                        $info_window->Label( -text => 'http://perl-node-interface.blogspot.com' )->pack;
						$info_window->resizable(0,0);
                      }
                ]
            ]
        ]
    );

    return $self;
}

sub get_window { return shift->get('window'); }

1;
