#!/usr/bin/perl -wT

# $Id: 50-RouteMap.t,v 1.2 2003/05/27 23:41:57 unimlo Exp $

use strict;

use Test::More tests => 20;

eval <<USES;
use Net::BGP::NLRI;
use Net::BGP::RIBEntry;
USES

my $hasbgp = $@ ? 0 : 1;

# Use
use_ok('Net::ACL');
use_ok('Net::ACL::RouteMapRule');
use Net::ACL::Rule qw( :rc :action );

# Construction
my $permit = new Net::ACL::RouteMapRule(Action => ACL_PERMIT);
my $deny = new Net::ACL::RouteMapRule(Action => ACL_DENY);
my $change = new Net::ACL::RouteMapRule(Action => ACL_DENY);

ok($permit->isa('Net::ACL::RouteMapRule'),'Permit construction 1');
ok($permit->isa('Net::ACL::Rule'),        'Permit construction 2');
ok($permit->action == ACL_PERMIT,         'Action permit value');
ok($permit->action_str eq 'permit',       'Action permit string');
ok($deny->isa('Net::ACL::RouteMapRule'),  'Deny construction 1');
ok($deny->isa('Net::ACL::Rule'),          'Deny construction 2');
ok($deny->action == ACL_DENY,             'Action deny value');
ok($deny->action_str eq 'deny',           'Action deny string');
$change->action(ACL_PERMIT);
ok($change->action == ACL_PERMIT,         'Action modify value');
$change->action_str('deny');
ok($change->action == ACL_DENY,           'Action modify string 1');
$change->action_str('pERMit');
ok($change->action == ACL_PERMIT,         'Action modify string 2');

my $aspath_comm = new Net::ACL::RouteMapRule(
	Action	=> ACL_CONTINUE
	Match	=> {
		ASPath		=> "^65001"
		},
	Set	=> {
		ASPath		=> "(65001 65002)",
		Community	=> [ qw(65001:200 65001:300) ]
		}
	);
ok($aspath_comm->isa('Net::ACL::RouteMapRule'),'Complex construction 1');
my $loc10to20 = new Net::ACL::RouteMapRule(
	Action	=> ACL_PERMIT,
	Match	=> {
		LocalPref =>	10
		},
	Set	=> {
		LocalPref =>	20
		}
	);
ok($loc10to20->isa('Net::ACL::RouteMapRule'),'Complex construction 2');
my $all = new Net::ACL::RouteMapRule(
	Action	=> ACL_PERMIT,
	Match	=> {
		ASPath		=> [ qw(65001 65002) ],
		Community	=> [ qw(65001:1 65001:2) ],
		MED		=> 20,
		Prefix		=> '127.0.0.0/8',
		Nexthop		=> '10.0.0.2'
		},
	Set	=> {
		Prepend		=> 65010,
		Community	=> [ qw(65001:20) ],
		MED		=> 50,
		Nexthop		=> '10.0.0.1'
		}
	);
ok($all->isa('Net::ACL::RouteMapRule'),'Complex construction 3');

my $nlri;
SKIP:
 {
  skip('Net::BGP::NLRI not installed',4) unless $hasbgp;
  $nlri = new Net::BGP::NLRI(LocalPref => 10);
  ok($nlri->isa('Net::BGP::NLRI'),'NLRI Construction');
  ok($nlri->local_pref == 10,'NLRI Data');
  ok($permit->match($nlri) == ACL_MATCH,'Permit Match NLRI');
  ok($deny->match($nlri)   == ACL_MATCH,'Deny Match NLRI');
 };

my $permitlist = new Net::ACL(
	Name => 'MyPermit',
	Type => 'route-map'
	);

