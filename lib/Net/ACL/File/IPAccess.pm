#!/usr/bin/perl

# $Id: IPAccess.pm,v 1.2 2003/05/27 22:42:05 unimlo Exp $

package Net::ACL::File::IPAccessRule;

use strict;
use vars qw( $VERSION @ISA );

## Inheritance ##

@ISA     = qw( Net::ACL::Rule );
$VERSION = '0.02';

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
 my $str = $net->base . ' ' . $net->hostmask if defined $net;
 return 'access-list ' . $name . ' ' . $this->action_str . ($str eq '' ? '' : ' ' . $str) . "\n";
}

## End of Net::ACL::File::IPAccessRule ##

package Net::ACL::File::IPAccess;

use strict;
use vars qw( $VERSION @ISA );

## Inheritance ##

@ISA     = qw( Net::ACL::File::Standard );
$VERSION = '0.02';

## Module Imports ##

use Net::ACL::File;
use Carp;

## Net::ACL::File Class Auto Registration Code ##

Net::ACL::File->add_listtype('access-list',__PACKAGE__,'access-list');

## Public Object Methods ##

sub loadmatch
{
 my ($this,$line) = @_;
 $line =~ s/ +/ /g;
 croak "Configuration line format error in line: '$line'"
	unless $line =~ /^access-list ([^ ]+) (permit|deny)(.*)$/i;
 my ($name,$action,$data) = ($1,$2,$3);
 $data =~ s/^ //;
 $data =~ s/ /#/;
 my $rule = new Net::ACL::File::IPAccessRule(
	Action	=> $action
	);
 $rule->add_match($rule->autoconstruction('Match','Net::ACL::Match::IP','IP',0,$data));
 $this->add_rule($rule);
 $this->name($name);
}

## POD ##

=pod

=head1 NAME

Net::ACL::File::IPAccess - IP access-lists loaded from configuration string.

=head1 DESCRIPTION

This module extends the Net::ACL::File::Standard class to handle
community-lists. See B<Net::ACL::File::Standard> for details.

=head1 SEE ALSO

B<Net::ACL>, B<Net::ACL::File>, B<Net::ACL::Standard>

=head1 AUTHOR

Martin Lorensen <bgp@martin.lorensen.dk>

=cut

## End of Net::ACL::File::IPAccess ##

1;
