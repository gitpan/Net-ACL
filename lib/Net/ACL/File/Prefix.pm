#!/usr/bin/perl

# $Id: Prefix.pm,v 1.1 2003/05/27 02:56:27 unimlo Exp $

package Net::ACL::File::PrefixRule;

use strict;
use vars qw( $VERSION @ISA );

## Inheritance ##

@ISA     = qw( Exporter Net::ACL::Rule );
$VERSION = '0.01';

## Module Imports ##

use Net::ACL::Rule;
use Carp;

## Public Object Methods ##

sub asconfig
{ # Don't check data - expect them to be constructed the right way!
 my $this = shift;
 my $name = shift;
 my $match = $this->{_match}->[0];
 my $net = $match->net if defined $match;
 my $str = $net->base . '/' . $net->bits if defined $net;
 return 'ip prefix-list ' . $name . ' ' . $this->action_str . ($str eq '' ? '' : ' ' . $str) . "\n";
}

## End of Net::ACL::File::PrefixRule ##

package Net::ACL::File::Prefix;

use strict;
use vars qw( $VERSION @ISA );

## Inheritance ##

@ISA     = qw( Exporter Net::ACL::File::Standard );
$VERSION = '0.01';

## Module Imports ##

use Net::ACL::File;
use Carp;

## Net::ACL::File Class Auto Registration Code ##

Net::ACL::File->add_knownlist('prefix-list',__PACKAGE__,'ip prefix-list');

## Public Object Methods ##

sub loadmatch
{
 my ($this,$line) = @_;
 croak "Configuration line format error in line: '$line'"
	unless $line =~ /^ip prefix-list ([^ ]+) (?:seq \d+ )?(permit|deny)(.*)$/i;
 my ($name,$action,$data) = ($1,$2,$3);
 $data =~ s/^ //;
 my $rule = new Net::ACL::File::PrefixRule(
	Action	=> $action
	);
 $rule->add_match($rule->autoconstruction('Match','Net::ACL::Match::Prefix','Prefix',$data));
 $this->add_rule($rule);
 $this->name($name);
}

## POD ##

=pod

=head1 NAME

Net::ACL::File::Prefix - Prefix-lists loaded from configuration string.

=head1 DESCRIPTION

This module extends the Net::ACL::File::Standard class to handle
prefix-lists. See B<Net::ACL::File::Standard> for details.

=head1 SEE ALSO

B<Net::ACL>, B<Net::ACL::File>, B<Net::ACL::Standard>

=head1 AUTHOR

Martin Lorensen <bgp@martin.lorensen.dk>

=cut

## End of Net::ACL::File::Prefix ##

1;
