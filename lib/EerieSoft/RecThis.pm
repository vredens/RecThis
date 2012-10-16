package EerieSoft::RecThis;

use 5.012003;
use strict;
use warnings;

use Carp;
use Data::Dumper;
use Time::HiRes qw(gettimeofday tv_interval);

require Exporter;

use constant {
	FATAL    => 0,
	ERROR    => 5,
	WARNING  => 10,
	NOTICE   => 15,
	INFO     => 20,
	DEBUG    => 25,
	TODO     => 30,
	OPTIMIZE => 35
};

our @ISA = qw(Exporter);

our @EXPORT_OK = ( qw(rec_this rec_this_dump rec_pstart rec_pend) );

our @EXPORT = qw();

our $VERSION = '1.00';

my $fh = (*STDERR);
my $min = 0;
my $max = DEBUG;
my $indent = 0;
my $timestamps = 1;
my $caller = 1;

# profiler global vars
my $pfh;
my $max_id = 0;
my $profiler = {};

sub close {
	close($fh);
}

sub init {
	my $opts = shift;
	
	if (defined $opts->{'file'}) {
		if (defined fileno($opts->{'file'})) {
			$fh = $opts->{'file'};
		} else {
			open($fh, defined $opts->{'reset'} ? '>' : '>>', $opts->{'file'}) or croak('Could not open file ' . $opts->{'file'});
		}
	}
	
	if (defined $opts->{'profiler-file'}) {
		if (defined fileno($opts->{'profiler-file'})) {
			$pfh = $opts->{'profiler-file'};
		} else {
			open($pfh, defined $opts->{'reset'} ? '>' : '>>', $opts->{'profiler-file'}) or croak('Could not open file ' . $opts->{'profiler-file'});
		}
	}
	
	# record levels
	if (defined $opts->{'min-level'}) {
		croak 'Invalid minimum level ' . $opts->{'min-level'} unless ($opts->{'min-level'} >= 0 and $opts->{'min-level'} <= 100);
		$min = $opts->{'min-level'};
	}
	if (defined $opts->{'max-level'}) {
		croak 'Invalid maximum level ' . $opts->{'max-level'} unless ($opts->{'max-level'} >= 0 and $opts->{'max-level'} <= 100);
		$max = $opts->{'max-level'};
	}

	# record display flags
	$indent = $opts->{'indent'} if (defined $opts->{'indent'});
	$timestamps = $opts->{'timestamp'} if (defined $opts->{'timestamp'});
	$caller = $opts->{'caller'} if (defined $opts->{'caller'});
	
	1;
}

sub rec_this($$) {
	my $_l = shift;
	my $_m = shift;
	
	# deal with empty messages
	$_m = defined ($_m) ? $_m : '';

	#$fh = (*STDERR) unless (defined $fh);

	if ($_l >= $min and $_l <= $max) {
		my $prefix = '';
		
		if ($timestamps) {
			my @_date = localtime;
			$prefix .= sprintf "[%.4d-%.2d-%.2d %.2d:%.2d:%.2d]", 1900 + $_date[5], $_date[4], $_date[3], $_date[2], $_date[1], $_date[0];
		}
		if ($caller) {
			my @_caller = caller;
			$prefix .= sprintf "[%s:%s]", $_caller[0], $_caller[2];
		}
		if ($indent) {
			$prefix .= '-' x $_l . ' ';
		} else {
			$prefix .= '[' . $_l . '] ';
		}

		print $fh $prefix . $_m . "\n";
	}
	
	1;
}

sub rec_this_dump($$) {
	rec_this(shift, Dumper(shift));
}

sub rec_pstart {
	my $id = $max_id++;
	
	# we reset back to 0 if we reach 50.000 profile runs
	$max_id = 0 if $max_id > 50000;

	$profiler->{$id} = [gettimeofday];
	
	print $id, "\n";
	
	return $id;
}

sub rec_pend {
	my ($id, $message) = @_;
	
	if (defined $profiler->{$id}) {
		printf $pfh "%.6f;%s\n", tv_interval($profiler->{$id}) * 1000, $message;
	}
}

1;

__END__

=head1 NAME

EerieSoft::RecThis - EerieSoftronics logging interface

=head1 SYNOPSIS

  use EerieSoft::RecThis;

  # use RecThis to open a file
  EerieSoft::RecThis::init({'file' => 'file.log', 'max-level' => EerieSoft::RecThis::DEBUG});

  # use our own filehandle which in this example is pointed at the STDIN of some record tool
  open(my $fh, '-| my_record_keeper_tool');
  EerieSoft::RecThis::init({'file' => $fh, 'max-level' => EerieSoft::RecThis::DEBUG});
  
  # the init function is completly OPTIONAL, default is to record to STDERR

  # log a message
  rec_this(3, 'Fatal error');
  
  # use the constants already defined for better readability
  rec_this(EerieSoft::RecThis::WARNING, 'WARN! pants on fire!');

  # dump avariable
  rec_this_dump(25, $my_var);

  # setup a profiler
  EerieSoft::RecThis::init({'profiler-file' => 'profile.log'});
  my $pname = rec_pstart();
  # YOUR CODE TO PROFILE
  rec_pstop($pname, 'MyProfileName');


=head1 DESCRIPTION

A very simple recorder for Perl. Some people might call this a Logger, but the term 'log' is
applied to records with strict rules, such as flight logs, ship logs, building entry/exit logs.
You don't register in a plane log something like 'I should pilot with my mikey mouse underwear
on the next flight'. We all know that developers tend to use 'logs' with all sort of messages
for different reasons such as debugging, maintenance, errors, etc. Well, that's why we have
different recording levels (ERROR, DEBUG, INFO, TODO, etc).

So, the correct term should be RECORDER and not logger. A log is a sub-set of record and I 
did want to make a pretty generic and SIMPLE tool.

The RecThis tool is only aimed at developers who need to record messages of how things are going
in their code. This means that RecThis only supports file logging (STDERR is a file, so is a pipe).
You can pass a file descriptor or a file path to the init function. If you pass nothing then STDERR
is the prefered output.

RecThis is not an Object, it's a collection of functions with a common, shared, state which you
can change anytime you want during your code but we recommend doing it only once. Objects polute
your code. Refrain from using them when you can (Perl is not Java).

You don't need to setup anything, just import it and use it's 2 functions and immediately start
seeing stuff in your STDERR.

This is a tool aimed at developers and not production systems but feel free to upgrade from it.

RecThis also supports something you don't see in any other "Logger" lib: indentation. Indentation
is a presentation form where the message is prefixed by a character replicated N times, where N
is the level of the mssage (for example, DEBUG messages have a level of 25, which means that 25 '-'
are inserted before the message. You might think this is just garbage but give it a try and you'll
find it helps. Specially if you use multiple log levels to find how deep in the caller stack you
are.

=head1 EXPORT

rec_this

rec_this_dump

rec_pstart

rec_pend

=head1 FUNCTIONS

=head2 setup (%options)

Sets all the options. Removes previous set options, including changing where to send messages.

Options are:

  - file: a file handle or a path to a file.
  - min-level: the minimum level of a message to record (default is 0)
  - max-level: the maximum level of a message to record (default is 50)
  - reset: only used if file is a path to a file, if so it opens the file for writting and not appending.
  - timestamps: true or false, show timestamps on messages
  - caller: true or false, show caller package and line on messages
  - indent: instead of just printing the record level number print '-' x level before the mssage instead.
  
That's it, that's all you can setup.

=head1 SEE ALSO

Nothing to see here, move along.

=head1 AUTHOR

JB "vredens" Ribeiro, E<lt>jbr at eerieguide dot comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by EerieSoftronics

=cut
