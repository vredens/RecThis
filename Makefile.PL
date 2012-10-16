use 5.012003;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'EerieSoft::RecThis',
    VERSION_FROM      => 'lib/EerieSoft/RecThis.pm',
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/EerieSoft/RecThis.pm', # retrieve abstract from module
       AUTHOR         => 'Vredens <jbr@eerieguide.com>') : ()),
);
