#!/usr/bin/perl

# $Id: IP.pm,v 1.6 2003/05/27 12:52:08 unimlo Exp $

package Net::ACL::Match::IP;

use strict;
use vars qw( $VERSION @ISA );

## Inheritance and Versioning ##

@ISA     = qw( Net::ACL::Match Exporter );
$VERSION = '0.01';

## Module Imports ##

use Carp;
use Net::ACL::Match;
use Net::ACL::Rule qw( :rc );
use Net::Netmask;

## Public Class Methods ##

sub new
{
 my $proto = shift;
 my $class = ref $proto || $proto;

 my $index = 0;
 if ($_[0] =~ /^#([0-9]+)$/)
  {
   shift;
   $index = $1;
  };

 my $this = {
	_index => $index,
        _net => new Net::Netmask(@_)
  };

 croak $this->{_net}->{'ERROR'} if defined $this->{_net}->{'ERROR'};

 bless($this, $class);

 return $this;
}

## Public Object Methods ##

sub match
{
 my $this = shift;
 return $this->{_net}->match($_[$this->{_index}]) ? ACL_MATCH : ACL_NOMATCH;
}

sub net
{
 my $this = shift;
 $this->{_net} = @_ ? ((ref $_[0] eq 'Net::Netmask') ? $_[0] : new Net::Netmask(@_)) : $this->{_net};
 return $this->{_net};
}

## POD ##

=pod

=head1 NAME

Net::ACL::Match::IP - Class matching IP addresses against an IP or network

=head1 SYNOPSIS

    use Net::ACL::Match::IP;

    # Constructor
    $match = new Net::ACL::Match::IP('10.0.0.0/8');
    $match = new Net::ACL::Match::IP('#1','10.0.0.0/8'); # $match->index(1);
		
    # Accessor Methods
    $netmaskobj = $match->net($netmaskobj);
    $netmaskobj = $match->net($net);
    $index = $match->index($index);
    $rc = $match->match($ip);

=head1 DESCRIPTION

This module is just a wrapper of the Net::Netmask module to allow it to
operate automaticly with B<Net::ACL::Rule>.

=head1 CONSTRUCTOR

I<new()> - create a new Net::ACL::Match::IP object

    $match = new Net::ACL::Match::IP('10.0.0.0/8');

This is the constructor for Net::ACL::Match::IP objects. It returns a
reference to the newly created object. Any arguments is parsed directly to the
constructor of B<Net::Netmask>. One exception is that if the first argument
is number prefixed with a #, the number is interpreted as the index in the
array given to the match method that should be matched.

=head1 ACCESSOR METHODS

I<net()>

The net method returns the B<Net::Netmask> object representing the network
matched. If called with a Net::Netmask object, the net used for matching is
changed to that object. If called with a anything else, the Net::Netmask
constructor will be used to convert it to a Net::Netmask object.

I<index()>

The index method returns the index of the argument that will be matched.
If called with an argument, the index is changed to that argument.

I<match()>

The match method invoke the B<match> method of the Net::Netmask object constructed
by B<new>. The index value defines which argument is passed on to B<new>.

=head1 SEE ALSO

B<Net::Netmask>, B<Net::ACL>,
B<Net::ACL::Rule>, B<Net::ACL::Match>

=head1 AUTHOR

Martin Lorensen <bgp@martin.lorensen.dk>

=cut

## End Package Net::ACL::Match::IP ##
 
1;
