#!/usr/bin/perl

# $Id: Regexp.pm,v 1.3 2003/05/28 14:38:59 unimlo Exp $

package Net::ACL::Match::Regexp;

use strict;
use vars qw( $VERSION @ISA );

## Inheritance and Versioning ##

@ISA     = qw( Net::ACL::Match::Scalar );
$VERSION = '0.03';

## Module Imports ##

use Net::ACL::Match::Scalar;
use Net::ACL::Rule qw( :rc );
use Carp;

## Public Object Methods ##

sub match
{
 my $this = shift;
 my $pattern = $this->{_value};
 return $_[$this->{_index}] =~ /$pattern/ ? ACL_MATCH : ACL_NOMATCH;
}

## POD ##

=pod

=head1 NAME

Net::ACL::Match::Regexp - Class matching a scalar data element

=head1 SYNOPSIS

    use Net::ACL::Match::Regexp;

    # Construction
    my $match = new Net::ACL::Match::Regexp(['^65001 [0-9 ]+ 65002$', 2]);

    # Accessor Methods
    $rc = $match->match(@data); # same as: $data[1] eq 42 ? ACL_MATCH : ACL_NOMATCH;

=head1 DESCRIPTION

This module is a very simpel array element testing with regular expresion
utility to allow simple value matching with B<Net::ACL::Rule>.

=head1 CONSTRUCTOR

    my $match = new Net::ACL::Match::Regexp(['^65001 [0-9 ]+ 65002$',2]);

This is the constructor for Net::ACL::Match::Regexp objects.
It returns a reference to the newly created object.

It takes one argument. If the argument is a array reference with one element,
the element will be used as a regexp pattern to matched with the first
argument to the match method.

If an array reference has more then one element, the second element should be
the argument number to be matched in the match method.

Otherwise, the value it self will be used as a regexp pattern to match the
first argument of the match method.

=head1 ACCESSOR METHODS

I<match()>

This function matches the arguments acording to the arguments of the
constructor and returns either ACL_MATCH or ACL_NOMATCH as exported by
B<NEt::ACL::Rule> with B<:rc>.

=head1 SEE ALSO

B<Net::ACL::Match>, B<Net::ACL::Rule>, B<Net::ACL>

=head1 AUTHOR

Martin Lorensen <bgp@martin.lorensen.dk>

=cut

## End Package Net::ACL::Match::Regexp ##
 
1;
