#!/usr/bin/perl -wT

# $Id: 30-SetScalar.t,v 1.1 2003/05/27 02:08:36 unimlo Exp $

use strict;

use Test::More tests => 19;

# Use
use_ok('Net::ACL::Set::Scalar');
use_ok('Net::ACL::Rule');
use Net::ACL::Rule qw( :rc );

# Construction
my $set1 = new Net::ACL::Set::Scalar(42);
ok(ref $set1 eq 'Net::ACL::Set::Scalar','Construction 1');
ok($set1->isa('Net::ACL::Set'),'Inheritence');

my $set2 = new Net::ACL::Set::Scalar([42,1]);
ok(ref $set2 eq 'Net::ACL::Set::Scalar','Construction 2');

my $set3 = new Net::ACL::Set::Scalar([42]);
ok(ref $set3 eq 'Net::ACL::Set::Scalar','Construction 3');

my $set4 = new Net::ACL::Set::Scalar([[42]]);
ok(ref $set4 eq 'Net::ACL::Set::Scalar','Construction 4');

ok(($set1->set(10,20,30))[0] eq 42,  'Set 1a');
ok(($set1->set(10,20,30))[1] eq 20,  'Set 1b');
ok(($set1->set(10,20,30))[2] eq 30,  'Set 1c');

ok(($set2->set(10,20,30))[0] eq 10,  'Set 2a');
ok(($set2->set(10,20,30))[1] eq 42,  'Set 2b');
ok(($set2->set(10,20,30))[2] eq 30,  'Set 2c');

ok(($set3->set(10,20,30))[0] eq 42,  'Set 3a');
ok(($set3->set(10,20,30))[1] eq 20,  'Set 3b');
ok(($set3->set(10,20,30))[2] eq 30,  'Set 3c');

ok(ref (($set4->set(10,20,30))[0]) eq 'ARRAY',
				     'Set 4a');
ok(($set4->set(10,20,30))[1] eq 20,  'Set 4b');
ok(($set4->set(10,20,30))[2] eq 30,  'Set 4c');

__END__
