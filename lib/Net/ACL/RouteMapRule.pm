#!/usr/bin/perl

# $Id: RouteMapRule.pm,v 1.8 2003/05/27 15:55:31 unimlo Exp $

package Net::ACL::RouteMapRule;

use strict;
use vars qw( $VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS @ACL_ROUTEMAP_INDEX );
use Carp;

## Inheritance and Versioning ##

@ISA     = qw( Net::ACL::Rule Exporter );
$VERSION = '0.01';

## Constants For Argument numbering ##

sub ACL_ROUTEMAP_ASPATH    { 0; };
sub ACL_ROUTEMAP_COMMUNITY { 1; };
sub ACL_ROUTEMAP_PREFIX    { 2; };
sub ACL_ROUTEMAP_NEXTHOP   { 3; };

## Export Tag Definitions ##

@ACL_ROUTEMAP_INDEX = qw (
	ACL_ROUTEMAP_ASPATH ACL_ROUTEMAP_COMMUNITY ACL_ROUTEMAP_PREFIX
	ACL_ROUTEMAP_NEXTHOP
	);

@EXPORT      = ();
@EXPORT_OK   = ( @ACL_ROUTEMAP_INDEX );
%EXPORT_TAGS = (
    index	=> [ @ACL_ROUTEMAP_INDEX ],
    ALL		=> [ @EXPORT, @EXPORT_OK ]
);


## Public Object Methods ##

sub autoconstruction
{
 my $this = shift;
 my $class = ref $this || $this;

 my ($type,$ruleclass,$arg,@values) = @_;
 if ( $arg =~ /aspath prepend (.*)$/i )
  {
   return $this->SUPER::autoconstruction($type,undef,'Add',[$1,ACL_ROUTEMAP_ASPATH]);
  }
 elsif ( $arg =~ /^community (.*)$/ )
  {
   return $this->SUPER::autoconstruction($type,undef,'Scalar',[$1,ACL_ROUTEMAP_COMMUNITY]);
  }
 elsif ( $arg =~ /^ip address (prefix-list) (.*)$/ )
  {
   return $this->SUPER::autoconstruction($type,undef,'List',{Name=>$2,Type=>$1,Index=>ACL_ROUTEMAP_PREFIX});
  }
 elsif ( $arg =~ /^ip next-hop (prefix-list) (.*)$/ )
  {
   return $this->SUPER::autoconstruction($type,undef,'List',{Name=>$2,Type=>$1,Index=>ACL_ROUTEMAP_NEXTHOP});
  };
 if ($ruleclass =~ / /)
  {
   croak "Unknown RouteMap construction key '$arg'";
  };
 return $this->SUPER::autoconstruction($type,$ruleclass,$arg,@values);
}

## POD ##

=pod

=head1 NAME

Net::ACL::RouteMapRule - Class representing a BGP-4 policy route-map rule

=head1 SYNOPSIS

    use Net::ACL::RouteMapRule;

    # Constructor
    $rule = new Net::ACL::RouteMapRule(
	Action	=> ACL_PERMIT,
        Match	=> {
		ASPath		=> [ $aspath_acl ],
		Community	=> [ $com_acl ],
		MED		=> [ 10, 20 ],
		Prefix		=> [ $prefix_acl ],
		Address		=> [ $ip1_acl ],
		Next_hop	=> [ $ip2_acl ],
		RouteSource	=> [ $ip3_acl ],
		Origin		=> IGP
		},
	Set	=> {
		ASPath		=> [ 65001, 65001 ],  # Prepend
		Community	=> [ qw( 65001:100 65001:200 ) ],
		Next_hop	=> '10.0.0.1',
		Local_Pref	=> 200,
		MED		=> 50,
		Origin		=> EGP,
		Weight		=> 42
		}
	);

    # Object Copy
    $clone = $rule->clone();

    # Accessor Methods
    ($rc,$nlri) = $rule->query($prefix, $nlri, $peer);

=head1 DESCRIPTION

This module represent a single route-map clause with a match part, a set part
and an action. This object is used by the Net::ACL::RouteMap object. It inherits
from Net::ACL::Rule, with the only chenged method being the B<autoconstructor>
method.

=head1 CONSTRUCTOR

I<new()> - create a new Net::ACL::RouteMapRule object

##### FILL IN HERE ######

I<query()>

##### FILL IN HERE ######

=head1 SEE ALSO

B<Net::ACL>, B<Net::ACL::Rule>, B<Net::ACL::RouteMap>,
B<Net::BGP>, B<Net::BGP::NLRI>, B<Net::BGP::Router>

=head1 AUTHOR

Martin Lorensen <bgp@martin.lorensen.dk>

=cut

## End Package Net::ACL::RouteMapRule ##
 
1;
