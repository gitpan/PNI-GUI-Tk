package PNI::GUI::Tk::Menu;
use strict;
use base 'PNI::Item';
use Tk::Dialog;

sub new {
    my $class = shift;
    my $arg   = {@_};
    my $self  = $class->SUPER::new(@_)
      or return PNI::Error::unable_to_create_item;

    # $controller is not required but should be a PNI::GUI::Tk::Controller
    my $controller = $arg->{controller};
    if ( defined $controller ) {
        $controller->isa('PNI::GUI::Tk::Controller')
          or return PNI::Error::invalid_argument_type;
    }
    $self->add( controller => $controller );

    my $window = $self->get_window;

    my $tk_window = $window->get_tk_main_window;

    my $tk_menu = $tk_window->Menu( -type => 'menubar' );

    # attach menu to its window
    $tk_window->configure( -menu => $tk_menu );

    # populate menu entries
    $tk_menu->Cascade(
        -label     => 'Scenario',
        -tearoff   => 1,
        -menuitems => [
            [
                Button   => 'Open',
                -command => [ sub { $controller->open_pni_file; } ]
            ],
            [
                Button   => 'Save',
                -command => [ sub { $controller->save_pni_file; } ]
            ],
            [
                Button   => 'Save as',
                -command => [ sub { $controller->save_as_pni_file; } ]
            ],
            [
                Button   => 'Close',
                -command => [ sub { $controller->close_window; } ]
            ],
            [
                Button   => 'Exit',
                -command => [ sub { Tk::exit(); } ]
            ]
        ]
    );
    $tk_menu->Cascade(
        -label     => '~Help',
        -tearoff   => 0,
        -menuitems => [
            [
                Button   => 'About',
                -command => [
                    sub {
                        my $info_window = $tk_window->Toplevel(
                            -title => 'Perl Node Interface' );
                        $info_window->geometry('200x150+100+100');
                        $info_window->Label( -text => $_ )
                          ->pack( -anchor => 'w' )
                          for (
                            'PNI version: ' . $PNI::VERSION,
                            'PNI::GUI::Tk version: ' . $PNI::GUI::Tk::VERSION,
                            'For more info point your browser to',
                            'http://perl-node-interface.blogspot.com'
                          );
                        $info_window->resizable( 0, 0 );
                      }
                ]
            ]
        ]
    );

    ### new: __PACKAGE__ . ' id=' . $self->id
    return $self;
}

sub get_controller { return shift->get('controller') }

sub get_window { return shift->get_controller->get_window; }

1;
__END__

=head1 NAME

PNI::GUI::Tk::Menu - 


=head1 METHODS

=head2 C<get_controller>

=head2 C<get_window>



=head1 AUTHOR

G. Casati , E<lt>fibo@cpan.orgE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2009-2011, Gianluca Casati

This program is free software, you can redistribute it and/or modify it
under the same terms of the Artistic License version 2.0 .

=cut
