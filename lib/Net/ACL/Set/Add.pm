#!/usr/bin/perl

# $Id: Add.pm,v 1.5 2003/05/29 00:08:44 unimlo Exp $

package Net::ACL::Set::Add;

use strict;
use vars qw( $VERSION @ISA );

## Inheritance and Versioning ##

@ISA     = qw( Net::ACL::Set::Scalar );
$VERSION = '0.04';

## Module Imports ##

use Net::ACL::Set::Scalar;
use Carp;

## Public Object Methods ##

sub set
{
 my $this = shift;
 my @data = @_;
 $data[$this->{_index}] += $this->{_value};
 return @data;
}

## POD ##

=pod

=head1 NAME

Net::ACL::Set::Add - Class adding a value to a data element

=head1 SYNOPSIS

    use Net::ACL::Set::Add;

    # Construction
    my $set = new Net::ACL::Set::Add(42,1);

    # Accessor Methods
    @data = $set->set(@data); # same as: $data[1] += 42;

=head1 DESCRIPTION

This module is a very simpel array element addition utility to allow
simple value addition with Net::ACL::Rule. Note that using overloading
of the "+=" operator, complex operation can be executed for objects.

=head1 CONSTRUCTOR

    my $set = new Net::ACL::Set::Add(42,1);

This is the constructor for Net::ACL::Set::Add objects.
It returns a reference to the newly created object.

The first argument is the argument number to set that should be modified.
The second arguement are the value added the the element.

=head1 ACCESSOR METHODS

I<set()>

This function modifies the arguments according to the arguments of the
constructor and returns them.

=head1 SEE ALSO

Net::ACL::Set, Net::ACL::Set::Scalar, Net::ACL

=head1 AUTHOR

Martin Lorensen <bgp@martin.lorensen.dk>

=cut

## End Package Net::ACL::Set::Add ##
 
1;
