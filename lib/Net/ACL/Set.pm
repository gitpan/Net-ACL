#!/usr/bin/perl

# $Id: Set.pm,v 1.5 2003/05/28 14:38:59 unimlo Exp $

package Net::ACL::Set;

use strict;
use Exporter;
use vars qw( $VERSION @ISA );

## Inheritance and Versioning ##

@ISA     = qw( Exporter );
$VERSION = '0.03';

## Module Imports ##

use Carp;

## Public Class Methods ##

sub new
{
 my $proto = shift;
 my $class = ref $proto || $proto;
 croak 'Cannot construct object of abstract class Net::ACL::Set'
	if $class eq 'Net::ACL::Set';
}

## Public Object Methods ##

sub set
{
 my $this = shift;
 my $class = ref $this || $this;
 croak 'Net::ACL::Set objects cannot set!'
	if $class eq 'Net::ACL::Set';

 croak "$class should reimplement the set method inhireted from Net::ACL::Set";
}

sub index
{
 my $this = shift;
 $this->{_index} = @_ ? shift : $this->{_index};
 return $this->{_index};
}

## POD ##

=pod

=head1 NAME

Net::ACL::Set - Abstract parent class of Set-classes

=head1 SYNOPSIS

    package Net::ACL::SetMyPackage;

    use Net::ACL::Set;
    @ISA     = qw( Net::ACL::Set );

    sub new { ... };
    sub set { ... };


    package main;

    # Construction
    my $set = new Net::ACL::SetMyPackage($args);

    # Accessor Methods
    @data = $set->set(@data);

=head1 DESCRIPTION

This is an abstract parent class for all B<Net::ACL::Set*>
classes. It is used by the B<Net::ACL::Rule> object.

It only has a constructor B<new> and a method B<set>. Both should be
replaced in any ancestor object.

=head1 CONSTRUCTOR

    my $set = new Net::ACL::SetMyPackage($args);

This is the constructor for Net::ACL::Set::* objects.
It returns a reference to the newly created object.
It takes one argument which should describe what to set.

=head1 ACCESSOR METHODS

I<set()>

This function should modify the data given as arguments (one or more) with
the data passed to the constructor and return the modifyed data.

=head1 SEE ALSO

B<Net::ACL::Rule>, B<Net::ACL>,
B<Net::ACL::Set::Scalar>

=head1 AUTHOR

Martin Lorensen <bgp@martin.lorensen.dk>

=cut

## End Package Net::ACL::Set ##
 
1;