#!/usr/bin/perl -wT

# $Id: 99-RouteMap.t,v 1.1 2003/05/27 02:08:36 unimlo Exp $

use strict;

use Test::More skip_all => 'Not implented yet!';

__END__

use Test::More tests => 25;

# Use
use_ok('Net::BGP::Policy::RouteMap::Entry');
use_ok('Net::BGP::Policy::RouteMap');

# Construction
my $accept = new Net::BGP::Policy::RouteMapEntry;
ok(ref $empty eq 'Net::BGP::RIBEntry','Simple construction');
my $data = new Net::BGP::RIBEntry(
	Prefix		=>	'10.0.0.0/8'
	);
ok(ref $data eq 'Net::BGP::RIBEntry','Complex construction');

# Copying
my $clone1 = clone Net::BGP::RIBEntry($data);
ok(ref $clone1 eq 'Net::BGP::RIBEntry','Clone construction');
my $clone = $clone1->clone;
ok(ref $clone eq 'Net::BGP::RIBEntry','Cloning');

# Prefix
ok($clone->prefix eq '10.0.0.0/8','Accessor: Prefix');
$clone->prefix('10.0.0.0/16');
ok($clone->prefix eq '10.0.0.0/16','Accessor: Prefix modifyer');

# Setup peers and NLRIs
my $nlri1 = new Net::BGP::NLRI(
	LocalPref	=>	20
	);
my $nlri2 = new Net::BGP::NLRI(
	LocalPref	=>	10
	);
my $peer1 = new Net::BGP::Peer();
my $peer2 = new Net::BGP::Peer();
my $peer3 = new Net::BGP::Peer();

# Update In
ok(ref $clone->update_in($peer1,$nlri1) eq 'Net::BGP::RIBEntry','Accessor: Update IN');
$clone->update_in($peer2,$nlri2);

# In
ok($clone->in->{$peer2} eq $nlri2,'Accessor: In');

# Update local
ok(  $clone->update_local,'Accessor: Update local 1');
ok(! $clone->update_local,'Accessor: Update local 2');

# Local
ok($clone->local eq $nlri2,'Accessor: Local');

# Update Out
my $policy_out;
$policy_out->{$peer2} = undef; 
$policy_out->{$peer3} = undef; 
my $changes_hr = $clone->update_out($policy_out);
ok(! exists $changes_hr->{$peer1},'Accessor: Update out 1');
ok($changes_hr->{$peer2} eq $nlri2,'Accessor: Update out 2');
ok($changes_hr->{$peer3} eq $nlri2,'Accessor: Update out 3');
$changes_hr = $clone->update_out($policy_out);
ok(! exists $changes_hr->{$peer1},'Accessor: Update out 4');
ok(! exists $changes_hr->{$peer2},'Accessor: Update out 5');
ok(! exists $changes_hr->{$peer3},'Accessor: Update out 6');

# Out
ok(! exists $clone->out->{$peer1},'Accessor: Out 1');
ok($clone->out->{$peer2} eq $nlri2,'Accessor: Out 2');
ok($clone->out->{$peer3} eq $nlri2,'Accessor: Out 3');

# As string
my $str = $clone->asstring;
ok(! ref $str,'Accessor: As string 1');
ok($str !~ /=HASH\(0x/,'Accessor: As string 2');

__END__
