#!/usr/bin/perl -wT

# $Id: 02-Netmask.t,v 1.1 2003/05/27 02:08:36 unimlo Exp $

use strict;

use Test::More tests => 4;

use_ok('Net::Netmask');

my %t = (
	'any'	=> '0.0.0.0/0',
	'10.0.0.0#0.255.255.255' => '10.0.0.0/8',
	'10.0.0.0:255.0.0.0' => '10.0.0.0/8'
	);

while (my ($key,$value) = each %t)
 {
  my $x = new Net::Netmask($key);
  ok($x->desc eq $value,$key);
  diag('A newer version of Net::Netmask should fix this!') unless $x->desc eq $value;
 };
