#!/usr/bin/perl -wT

# $Id: 01-Reconfig.t,v 1.2 2003/05/27 16:12:06 unimlo Exp $

use strict;

use Test::More tests => 2;

use_ok('Cisco::Reconfig');

my $x = Cisco::Reconfig::stringconfig(<<CONF);
a b c d
a b c e
CONF
my $y = Cisco::Reconfig::stringconfig(<<CONF);
a b c d
a b c e
h i j k
CONF

$x = $x->get('a b c');
$y = $y->get('a b c');

$x =~ s/\n/\|/g;
$y =~ s/\n/\|/g;
ok("$x" eq "$y","The get function of Cisco::Reconfig does strange! A newer version should fix this!");
