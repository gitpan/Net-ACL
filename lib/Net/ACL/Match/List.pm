#!/usr/bin/perl

# $Id: List.pm,v 1.4 2003/05/27 13:53:17 unimlo Exp $

package Net::ACL::Match::List;

use strict;
use vars qw( $VERSION @ISA );

## Inheritance and Versioning ##

@ISA     = qw( Net::ACL::Match Exporter );
$VERSION = '0.01';

## Module Imports ##

use Carp;
use Scalar::Util qw( blessed );
use Net::ACL::Match;
use Net::ACL::Rule qw( :rc :action );
use Net::ACL::Bootstrap;

## Public Class Methods ##

sub new
{
 my $proto = shift;
 my $class = ref $proto || $proto;

 my $this = {
        _lists => [],
	_index => 0
  };

 bless($this, $class);

 my $arg = shift;

 if ((ref $arg eq 'Net::ACL')
  || (! ref $arg))
  {
   $this->add_list($arg);
  }
 elsif (ref $arg eq 'HASH')
  {
   my ($k) = (grep /Index/i, keys %{$arg});
   $k ||= '';
   $this->{_index} = $arg->{$k} || 0;
   delete $arg->{$k};
   $this->add_list($arg);
  }
 elsif (ref $arg eq 'ARRAY')
  {
   foreach my $sarg (@{$arg})
    {
     $this->add_list($sarg);
    }
  };

 croak 'Need at least one access-list to match' unless scalar  $this->{_lists};

 return $this;
}

## Public Object Methods ##

sub add_list
{
 my ($this,$arg) = @_;
 my $l = (blessed $arg) ? $arg : renew Net::ACL::Bootstrap(%{$arg});
 push(@{$this->{_lists}},$l);
}

sub match
{
 my $this = shift;
 my @data = @_;
 foreach my $list (@{$this->{_lists}})
  {
   return ACL_NOMATCH unless $list->match(@data) == ACL_PERMIT;
  }
 return ACL_MATCH;
}

sub names
{
 my $this = shift;
 return map { $_->name; } @{$this->{_lists}};
}

## POD ##

=pod

=head1 NAME

Net::ACL::Match::List - Class matching data against one or more access-lists

=head1 SYNOPSIS

    use Net::ACL::Match::List;

    # Constructor
    $match = new Net::ACL::Match::List( [
	Type	=> 'prefix-list'
	Name	=> 42
	] );
		
    # Accessor Methods
    $rc = $match->match('127.0.0.0/20');

=head1 DESCRIPTION

This module match data against one or more access-lists. It only matches if
data if data is permited by all access-lists.

=head1 CONSTRUCTOR

I<new()> - create a new Net::ACL::Match::List object

    $match = new Net::ACL::Match::List( [
	Type	=> 'prefix-list'
	Name	=> 42
	] );

This is the constructor for Net::ACL::Match::List objects. It
returns a reference to the newly created object. It takes one argument,
which can have one of the following types:

I<Net::ACL> - An access-list to be matched against.

I<HASH reference> - A reference to a hash passed to Net::ACL->renew

I<SCALAR> - A scalar passed to Net::ACL->renew

I<ARRAY reference> - A reference to an array one of the abover 3 types. Used
to match multiple lists.


=head1 ACCESSOR METHODS

I<match()>

The match method verifies if the data is permitted by all access-lists
supplied to the constructor. Returns ACL_MATCH if it does, otherwise
ACL_NOMATCH.

=head1 SEE ALSO

B<Net::ACL::Match>, B<Net::ACL::Rule>, B<Net::ACL>

=head1 AUTHOR

Martin Lorensen <bgp@martin.lorensen.dk>

=cut

## End Package Net::ACL::Match::List ##
 
1;
