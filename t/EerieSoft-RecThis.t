# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl EerieSoft-LogThis.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use File::Temp qw/ tempfile /;

use Test::More tests => 3;

BEGIN { use_ok('EerieSoft::RecThis') };

my ($fh, $filename) = tempfile();

ok(EerieSoft::RecThis::set_defaults(50, $filename), 'Set defaults');
ok(EerieSoft::RecThis::RecThis(10, 'ERROR'), 'Record');

my $l = <$fh>;
ok($l =~ /^\[\d{4}(-\d{2}){2} \d{2}(:\d{2}){2}\]\[\d+\]---------- ERROR$/, 'Record is correct');

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

