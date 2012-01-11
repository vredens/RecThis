package EerieSoft::RecThis;

use 5.012003;
use strict;
use warnings;

use Carp;
use Data::Dumper;

require Exporter;

use constant {
	FATAL   => 0,
	ERROR   => 10,
	WARNING => 20,
	NOTICE  => 30,
	INFO    => 40,
	DEBUG   => 50,
	TODO    => 60
};

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use EerieSoft::LogThis ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '1.00';

our $default_fh;
our $default_ll = ERROR;

sub set_defaults($$) {
	my $_f = shift;
	my $_ll = shift;
	
	if (defined fileno($_f)) {
		$default_fh = $_f;
	} elsif(-w $_f) {
		open($default_fh, '>>', $_f) or croak('Could not open file ' . $_f);
	} else {
		croak 'You did not provide a writable file or filehandle';
	}
	croak 'Invalid minimum log level ' . $_ll unless ($_ll >= 0 and $_ll <= 100);
	$default_ll = $_ll;
}


sub new($$) {
	my $class = shift;
	my $_ll = shift;

	$default_fh = (*STDERR) unless (defined $default_fh);
	
	my $self = \$_ll;
	
	bless($self, $class);
}

sub RecThis($$$) {
	my $self = shift;
	my $_l = shift;
	my $_m = shift;

	print $default_fh, '[' . `date %Y-%m-%d %H:%M:%i` . '][' . $_l . ']' . '-' x $_l . ' ' . $_m . "\n" if ($_l >= 0 and $_l <= $$self);
}

sub RecThisDump($$$) {
	my $self = shift;
	my $_l = shift;
	my $_o = shift;
	
	print $default_fh, '[' . `date %Y-%m-%d %H:%M:%i` . '][' . $_l . ']' . '-' x $_l . ' ' . Dumper($_o) . "\n" if ($_l >= 0 and $_l <= $$self);
}

# Preloaded methods go here.

1;

__END__
=head1 NAME

EerieSoft::LogThis - EerieSoftronics logging interface

=head1 SYNOPSIS

  use EerieSoft::RecThis;
  
  # use RecThis to open a file
  EerieSoft::RecThis::init('file.log', EerieSoft::RecThis::DEBUG_LEVEL);
  
  # use our own filehandle which in this example is pointed at the STDIN of some record tool
  open(my $fh, '-| my_record_keeper_tool');
  EerieSoft::RecThis::init($fh, EerieSoft::RecThis::DEBUG_LEVEL);
  
  # log a message
  RecThis(0, 'Fatal error');
  
  # dump a variable
  RecThisDump(0, $my_var);

=head1 DESCRIPTION

A very simple recorder for Perl. Some people might call this a Logger, but the term 'log' is 
applied to records with strict rules, such as flight logs, ship logs, building entry/exit logs.
You don't register in a plane log something like 'I should pilot with my mikey mouse underwear
on the next flight'. We all know that developers tend to use 'logs' with all sort of messages
for different reasons such as debugging, maintenance, errors, etc. Well, that's why we have
different records (ERROR, DEBUG, INFO, TODO, etc).

So, the correct term should be RECORDER and not logger. Using mathematical terms, a log is a
sub-set of record and we did want to make a pretty generic tool.

Also, we didn't want to overcomplicate things, so the RecThis tool is only aimed at file logging.  

=head2 EXPORT

RecThis

RecThisDump


=head1 SEE ALSO

Nothing to see here, move along.

=head1 AUTHOR

Joao Bernardo Ribeiro, E<lt>jbr@eeriesoftronics.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by EerieSoftronics


=cut
