#!/usr/bin/perl

# $Id: Scalar.pm,v 1.3 2003/05/26 22:02:13 unimlo Exp $

package Net::ACL::Match::Scalar;

use strict;
use Exporter;
use vars qw( $VERSION @ISA );

## Inheritance and Versioning ##

@ISA     = qw( Net::ACL::Match Exporter );
$VERSION = '0.01';

## Module Imports ##

use Net::ACL::Match;
use Net::ACL::Rule qw( :rc );
use Carp;

## Public Class Methods ##

sub new
{
 my $proto = shift;
 my $class = ref $proto || $proto;
 my $value = shift;
 my $index = 0;
 if (ref $value eq 'ARRAY')
  {
   $index = $value->[1] || 0;
   $value = $value->[0];
  };
 my $this = {
	_value => $value,
	_index => $index
	};
 bless($this,$class);
 return $this;
}

## Public Object Methods ##

sub match
{
 my $this = shift;
 return $_[$this->{_index}] eq $this->{_value} ? ACL_MATCH : ACL_NOMATCH;
}

sub value
{
 my $this = shift;
 $this->{_value} = @_ ? shift : $this->{_value};
 return $this->{_value};
}

## POD ##

=pod

=head1 NAME

Net::ACL::Match::Scalar - Class matching a scalar data element

=head1 SYNOPSIS

    use Net::ACL::Match::Scalar;

    # Construction
    my $match = new Net::ACL::Match::Scalar([42,1]);

    # Accessor Methods
    $rc = $match->match(@data); # same as: $data[1] eq 42 ? ACL_MATCH : ACL_NOMATCH;

=head1 DESCRIPTION

This module is a very simpel array element testing utility to allow
simple value matching with B<Net::ACL::Rule>.

=head1 CONSTRUCTOR

    my $match = new Net::ACL::Match::Scalar(42,1);

This is the constructor for Net::ACL::Match::Scalar objects.
It returns a reference to the newly created object.

It takes one argument. If the argument is a array reference with one element,
the element will be matched with the first argument to the match method.

If an array reference has more then one element, the second element should be
the argument number to be matched in the match method.

Otherwise, the value it self will be matched with the first argument of
the match method.

=head1 ACCESSOR METHODS

I<match()>

This function matches the arguments acording to the arguments of the
constructor and returns either ACL_MATCH or ACL_NOMATCH as exported by
B<NEt::ACL::Rule> with B<:rc>.

=head1 SEE ALSO

B<Net::ACL::Match>, B<Net::ACL::Rule>, B<Net::ACL>, B<Net::ACL::Set::Scalar>

=head1 AUTHOR

Martin Lorensen <bgp@martin.lorensen.dk>

=cut

## End Package Net::ACL::Match::Scalar ##
 
1;
