#!/usr/bin/perl

# $Id: RouteMapRule.pm,v 1.13 2003/05/29 00:08:44 unimlo Exp $

package Net::ACL::RouteMapRule;

use strict;
use vars qw( $VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS @ACL_ROUTEMAP_INDEX );

## Inheritance and Versioning ##

@ISA     = qw( Net::ACL::Rule );
$VERSION = '0.04';

## Module Imports ##

use Carp;
use Net::ACL::Rule;

## Constants For Argument numbering ##

sub ACL_ROUTEMAP_ASPATH    { 0; };
sub ACL_ROUTEMAP_COMMUNITY { 1; };
sub ACL_ROUTEMAP_PREFIX    { 2; };
sub ACL_ROUTEMAP_NEXTHOP   { 3; };
sub ACL_ROUTEMAP_LOCALPREF { 4; };
sub ACL_ROUTEMAP_MED       { 5; };

## Export Tag Definitions ##

@ACL_ROUTEMAP_INDEX = qw (
	ACL_ROUTEMAP_ASPATH ACL_ROUTEMAP_COMMUNITY ACL_ROUTEMAP_PREFIX
	ACL_ROUTEMAP_NEXTHOP ACL_ROUTEMAP_LOCALPREF ACL_ROUTEMAP_MED
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
   return $this->SUPER::autoconstruction($type,undef,'Add',ACL_ROUTEMAP_ASPATH,$1);
  }
 elsif ( $arg =~ /^community(.*)$/i )
  {
   my $data = $1;
   $data =~ s/^ //;
   $data = $values[0] if $data eq '';
   return $this->SUPER::autoconstruction($type,undef,'Scalar',ACL_ROUTEMAP_COMMUNITY,$data);
  }
 elsif ( $arg =~ /^ip (address|next-hop) ((?:prefix-list )|)(.*)$/ )
  {
   my $index = $1 eq 'address' ? ACL_ROUTEMAP_PREFIX : ACL_ROUTEMAP_NEXTHOP;
   my $ltype = $2 eq '' ? 'access-list' : 'prefix-list';
   my @lists;
   foreach my $list (split(/ /,$3))
    {
     if ($list =~ /^\d{3}$/)
      {
       push(@lists,{Name=>$list,Type=>'extended-access-list'});
      }
     else
      {
       push(@lists,{Name=>$list,Type=>$ltype});
      };
    };
   return $this->SUPER::autoconstruction($type,undef,'List',$index,@lists);
  }
 elsif ($arg =~ /next[ _-]?hop/i )
  {
   if ($type eq 'Set')
    {
     return $this->SUPER::autoconstruction($type,undef,'Scalar',ACL_ROUTEMAP_NEXTHOP,@values);
    };
   if ($values[0] =~ /(prefix-list) (.*)$/)
    {
     return $this->SUPER::autoconstruction($type,undef,'List',ACL_ROUTEMAP_NEXTHOP,Name=>$2,Type=>$1);
    };
   return $this->SUPER::autoconstruction($type,undef,'IP',ACL_ROUTEMAP_NEXTHOP,@values);
  }
 elsif ( $arg =~ /MED/i )
  {
   return $this->SUPER::autoconstruction($type,undef,'Scalar',ACL_ROUTEMAP_MED,@values);
  }
 elsif ( $arg =~ /local[ _-]?pref(?:erence)?(?: (\d+))?$/i )
  {
   my $val = $1 || $values[0];
   return $this->SUPER::autoconstruction($type,undef,'Scalar',ACL_ROUTEMAP_LOCALPREF,$val);
  }
 elsif (($arg =~ /as[ _-]?path(?: (.*))?$/i ) && ( $type eq 'Match'))
  {
   my @lists;
   my @l = defined $1 ? $1 : @values;
   foreach my $list (@l)
    {
     push(@lists,{Name=>$list,Type=>'as-path-list'});
    };
   return $this->SUPER::autoconstruction($type,undef,'List',ACL_ROUTEMAP_ASPATH,@lists);
  }
 elsif (($arg =~ /(?:as[ _-]?path)|(?:prepend)/i ) && ( $type eq 'Set'))
  {
   return $this->SUPER::autoconstruction($type,undef,'Add',ACL_ROUTEMAP_ASPATH,@values);
  }
 elsif (($arg =~ /prefix/i ) && ( $type eq 'Match'))
  {
   return $this->SUPER::autoconstruction($type,undef,'Prefix',ACL_ROUTEMAP_PREFIX,@values);
  }
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

Inherited from

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
