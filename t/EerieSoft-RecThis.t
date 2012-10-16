# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl EerieSoft-LogThis.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use File::Temp qw/ tempfile /;
use Fcntl qw/:seek/;

use Test::More;

BEGIN { use_ok('EerieSoft::RecThis') };

my ($fh, $filename) = tempfile();

{
	ok(EerieSoft::RecThis::init({'file' => $filename, 'max-level' => 50}), 'Set defaults');
	ok(EerieSoft::RecThis::rec_this(10, 'ERROR'), 'Record');
	ok(EerieSoft::RecThis::rec_this_dump(20, {'lol' => 'ERROR'}), 'Record Dump');
	ok(EerieSoft::RecThis::close(), 'close');
}

unlink $filename;

done_testing();

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

