#!/usr/bin/perl

# $Id: IPAccessExt.pm,v 1.3 2003/05/27 22:42:05 unimlo Exp $

package Net::ACL::File::IPAccessExtRule;

use strict;
use vars qw( $VERSION @ISA );

## Inheritance ##

@ISA     = qw( Net::ACL::IPAccessExtRule );
$VERSION = '0.02';

## Module Imports ##

use Net::ACL::IPAccessExtRule qw( :index );
use Carp;

## Public Object Methods ##

sub asconfig
{ # Don't check data - expect them to be constructed the right way!
 my $this = shift;
 my ($proto,$from,$to) = ('n/a','n/a','n/a');
 foreach my $match (@{$this->{_match}})
  {
   if ($match->index == ACL_EIA_PROTO)
    {
     $proto = $match->value;
    }
   elsif ($match->index == ACL_EIA_FROM)
    {
     my $net = $match->net;
     $from = defined $net ? $net->base . ' ' . $net->hostmask : '';
    }
   elsif ($match->index == ACL_EIA_TO)
    {
     my $net = $match->net;
     $to = defined $net ? $net->base . ' ' . $net->hostmask : '';
    };
  };
 return ' ' . $this->action_str . " $proto $from $to\n";
}

## End of Net::ACL::File::IPAccessExtRule ##

package Net::ACL::File::IPAccessExt;

use strict;
use vars qw( $VERSION @ISA );

## Inheritance ##

@ISA     = qw( Net::ACL::File::Standard );
$VERSION = '0.02';

## Module Imports ##

use Net::ACL::File::Standard;
use Net::ACL::IPAccessExtRule qw( :index );
use Carp;

## Net::ACL::File Class Auto Registration Code ##

Net::ACL::File->add_listtype('extended-access-list',__PACKAGE__,'ip access-list extended');

## Public Object Methods ##

sub loadmatch
{
 my ($this,$line,$super) = @_;

 $line =~ s/ +/ /g;
 croak "Configuration line format error in line: '$line'"
	unless $line =~ /^ (permit|deny) ([^ ]+) (.*)$/i;
 my ($action,$proto,$data) = ($1,$2,$3);
 $data =~ s/^ //;
 my @data = split(/ /,$data);
 my $from = shift(@data);
 $from .= ' ' . shift(@data) unless ($from eq 'any');
 my $to = shift(@data);
 $to .= ' ' . shift(@data) unless ($to eq 'any');
 $to =~ s/ /#/;
 $from =~ s/ /#/;
 my $rule = new Net::ACL::File::IPAccessExtRule(
	Action	=> $action
	);
 $rule->add_match($rule->autoconstruction('Match','Net::ACL::Match::Scalar','Scalar',ACL_EIA_PROTO,$proto));
 $rule->add_match($rule->autoconstruction('Match','Net::ACL::Match::IP','IP',ACL_EIA_FROM,$from));
 $rule->add_match($rule->autoconstruction('Match','Net::ACL::Match::IP','IP',ACL_EIA_TO,$to));
 $this->add_rule($rule);
 $this->name($1)
	if ! defined($this->name)
	 && $super =~ /ip access-list extended (.*)$/;
}

sub asconfig
{
 my $this = shift;
 return "ip access-list extended " . $this->name . "\n" . $this->SUPER::asconfig(@_);
}

## POD ##

=pod

=head1 NAME

Net::ACL::File::IPAccessExt - Extended IP access-lists loaded from configuration string.

=head1 DESCRIPTION

This module extends the Net::ACL::File::Standard class to handle
community-lists. See B<Net::ACL::File::Standard> for details.

=head1 SEE ALSO

B<Net::ACL>, B<Net::ACL::File>, B<Net::ACL::Standard>, B<Net::ACL::IPAccessExtRule>

=head1 AUTHOR

Martin Lorensen <bgp@martin.lorensen.dk>

=cut

## End of Net::ACL::File::IPAccessExt ##

1;
