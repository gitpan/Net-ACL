#!/usr/bin/perl

# $Id: Match.pm,v 1.6 2003/05/28 14:38:59 unimlo Exp $

package Net::ACL::Match;

use strict;
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
 croak 'Cannot construct object of abstract class Net::ACL::Match'
	if $class eq 'Net::ACL::Match';
}

## Public Object Methods ##

sub match
{
 my $this = shift;
 my $class = ref $this || $this;
 croak __PACKAGE__ . ' objects cannot match!'
	if $class eq __PACKAGE__;

 croak "$class should reimplement the match method inhireted from " . __PACKAGE__;
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

Net::ACL::Match - Abstract parent class of Match-classes

=head1 SYNOPSIS

    package Net::ACL::MatchMyPackage;

    use Net::ACL::Match;
    @ISA     = qw( Net::ACL::Match );

    sub new { ... };
    sub match { ... };


    package main;

    # Construction
    my $match = new Net::ACL::MatchMyPackage($args);

    # Accessor Methods
    $rc = $match->match(@data);
    $index = $match->index($index);

=head1 DESCRIPTION

This is an abstract parent class for all B<Net::ACL::Match*>
classes. It is used by the B<Net::ACL::Rule> object.

It only has a constructor B<new> and two methods B<match> and B<index>.
Both new and match should be replaced in any ancestor object.

=head1 CONSTRUCTOR

    my $match = new Net::ACL::MatchMyPackage($args);

This is the constructor for Net::ACL::Match* objects.
It returns a reference to the newly created object.
It takes one argument which should describe what to match.

=head1 ACCESSOR METHODS

I<match()>

This function should match the data given as arguments (one or more) with
the data passed to the constructor and return either ACL_MATCH or
ACL_NOMATCH as exported by the ":rc" exporter symbol of
B<Net::ACL::Rule>.

I<index()>

This function return the argument number that matched any sub-class.
Called with an argument, the argument is used as the new value.

=head1 SEE ALSO

B<Net::ACL::Rule>, B<Net::ACL>,
B<Net::ACL::Match::IP>, B<Net::ACL::Match::Prefix>,
B<Net::ACL::Match::List>, B<Net::ACL::Match::Scalar>,
B<Net::ACL::Match::Regexp>

=head1 AUTHOR

Martin Lorensen <bgp@martin.lorensen.dk>

=cut

## End Package Net::ACL::Match ##
 
1;
