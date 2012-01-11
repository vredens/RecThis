# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl EerieSoft-LogThis.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use Test::More tests => 3;

BEGIN { use_ok('EerieSoft::RecThis') };


my $o = new EerieSoft::RecThis(3);

isa_ok($o, 'EerieSoft::RecThis');
can_ok($o, qw/RecThis RecThisDump/);

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

