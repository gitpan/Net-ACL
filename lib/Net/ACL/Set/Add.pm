#!/usr/bin/perl

# $Id: Add.pm,v 1.1 2003/05/27 12:52:53 unimlo Exp $

package Net::ACL::Set::Add;

use strict;
use Exporter;
use vars qw( $VERSION @ISA );

## Inheritance and Versioning ##

@ISA     = qw( Net::ACL::Set::Scalar Exporter );
$VERSION = '0.01';

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

Net::ACL::Set::Scalar - Class replacing a scalar data element

=head1 SYNOPSIS

    use Net::ACL::Set::Scalar;

    # Construction
    my $set = new Net::ACL::Set::Scalar([42,1]);

    # Accessor Methods
    @data = $set->set(@data); # same as: $data[1] = 42;

=head1 DESCRIPTION

This module is a very simpel array ellement replacement utility to allow
simple value replacement with B<Net::ACL::Rule>.

=head1 CONSTRUCTOR

    my $set = new Net::ACL::Set::Scalar(42,1);

This is the constructor for Net::ACL::Set::Scalar objects.
It returns a reference to the newly created object.

It takes one argument. If the argument is a array reference with one element,
the element will be placed instead of the first argument to the set method.

If an array reference has more then one element, the second element should be
the argument number to br replaced in the set method.

Otherwise, the value will directly be used instead of the first argument of
the set method.

=head1 ACCESSOR METHODS

I<set()>

This function modifyes the arguments acording to the arguments of the
constructor and returns them.

=head1 SEE ALSO

B<Net::ACL::Set>, B<Net::ACL::Rule>, B<Net::ACL>

=head1 AUTHOR

Martin Lorensen <bgp@martin.lorensen.dk>

=cut

## End Package Net::ACL::Set::Scalar ##
 
1;
