#!/usr/bin/perl

# $Id: Prefix.pm,v 1.1 2003/05/25 18:51:16 unimlo Exp $

package Net::ACL::Match::Prefix;

use strict;
use vars qw( $VERSION @ISA );

## Inheritance and Versioning ##

@ISA     = qw( Net::ACL::Match::IP Exporter );
$VERSION = '0.01';

## Module Imports ##

use Carp;
use Net::ACL::Match::IP;
use Net::ACL::Rule qw( :rc );
use Net::Netmask;

## Public Object Methods ##

sub match
{
 my $this = shift;
 my $other = new Net::Netmask(shift);
 return ($this->{_net}->base eq $other->base)
     && ($this->{_net}->bits == $other->bits) ? ACL_MATCH : ACL_NOMATCH;
}

## POD ##

=pod

=head1 NAME

Net::ACL::Match::Prefix - Class matching IP network prefixes.

=head1 SYNOPSIS

    use Net::ACL::Match::Prefix;

    # Constructor
    $match = new Net::ACL::Match::Prefix('10.0.0.0/8');
		
    # Accessor Methods
    $rc = $match->match('10.0.0.0/16'); # ACL_NOMATCH
    $rc = $match->match('127.0.0.0/8'); # ACL_NOMATCH
    $rc = $match->match('10.0.0.0/8');  # ACL_MATCH

=head1 DESCRIPTION

This module is just a wrapper of the Net::Netmask module to allow it to
operate automaticly with B<Net::ACL::Rule>.

=head1 CONSTRUCTOR

I<new()> - create a new Net::ACL::Match::Prefix object

    $match = new Net::ACL::Match::Prefix('10.0.0.0/8');

This is the constructor for Net::ACL::Match::Prefix objects. It returns a
reference to the newly created object. Any arguments is parsed directly to the
constructor of B<Net::Netmask>.

=head1 ACCESSOR METHODS

I<match()>

The method uses Net::Netmask to verify that the base address and the size of
the prefixes are the same.

=head1 SEE ALSO

B<Net::Netmask>, B<Net::ACL>,
B<Net::ACL::Rule>, B<Net::ACL::Match::IP>, B<Net::ACL::Match>

=head1 AUTHOR

Martin Lorensen <bgp@martin.lorensen.dk>

=cut

## End Package Net::ACL::Match::Prefix ##
 
1;
