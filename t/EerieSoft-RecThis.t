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
	ok(EerieSoft::RecThis::set_defaults($filename, 50), 'Set defaults');
	ok(EerieSoft::RecThis::RecThis(10, 'ERROR'), 'Record');
	ok(EerieSoft::RecThis::close(), 'close');
}

#seek $fh, 0, SEEK_SET;
my $l;
ok($l = <$fh>, 'read a line');
ok($l =~ /^\[\d{4}(-\d{2}){2} \d{2}(:\d{2}){2}\]\[\d+\]---------- ERROR$/, 'Record is correct');

unlink $filename;

done_testing();

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

