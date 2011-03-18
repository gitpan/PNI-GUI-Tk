use 5.008008008;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'PNI-GUI-Tk',
    VERSION_FROM => 'lib/PNI/GUI/Tk.pm',
    EXE_FILES    => ['pniguitk.pl'],
    PREREQ_PM    => {
        PNI           => '0.11',
        PNI::Node::Tk => '0.11'
    },
    (
        $] >= 5.005
        ? (
            ABSTRACT_FROM => 'lib/PNI/GUI/Tk.pm',
            AUTHOR        => 'G. Casati <fibo@cpan.org>'
          )
        : ()
    ),
);
