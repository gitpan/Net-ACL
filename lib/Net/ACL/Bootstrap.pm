#!/usr/bin/perl

# $Id: Bootstrap.pm,v 1.4 2003/05/27 23:41:50 unimlo Exp $

package Net::ACL::Bootstrap;

use strict;
use vars qw( $VERSION @ISA $AUTOLOAD );

## Inheritance and Versioning ##

@ISA     = qw( Exporter );
$VERSION = '0.02';

## Module Imports ##

use Carp;
use Net::ACL;

## Public Class Methods ##

sub renew
{
 my $proto = shift;
 my $class = ref $proto || $proto;
 
 my $this = renew Net::ACL(@_);
 return $this if defined $this;

 # Try to bootstrap!
 my ($name,$type) = (undef,$class);
 while ( defined(my $arg = shift) )
  {
   my $value = shift;
   if ( $arg =~ /name/i )
    {
     $name = $value;
    }
   elsif ( $arg =~ /type/i )
    {
     $type = $value;
    }
   else
    {
     croak "Can only bootstrap using name/type data - Not '$arg'.";
    };
  };

 $this = {};
 bless($this, $class);
 @{$this}{qw(_name _type _realist)} = ($name,$type,undef),
 return $this;
}

sub AUTOLOAD
{
 my $method = $AUTOLOAD;
 my $this = shift;
 my $class = ref $this || $this;
 $method =~ s/${class}:://;
 $this->fetch unless (defined $this->{_reallist});
 $this->{_reallist}->$method(@_);
}

sub DESTROY
{ # Don't do anything - But don't proxy this!
}

sub fetch
{
 my $this = shift;
 $this->{_reallist} = renew Net::ACL(
	Name	=> $this->{_name},
	Type	=> $this->{_type}
	);
 croak "Match with non-existing access-list!" unless defined $this->{_reallist};
}

## POD ##

=pod

=head1 NAME

Net::ACL::Bootstrap - A proxy/bootstrapper class for the Net::ACL class

=head1 SYNOPSIS

    use Net::ACL::Bootstrap;

    # Constructor
    $list = renew Net::ACL::Bootstrap(
	Name    => 'MyACL',
	Type	=> 'prefix-list',
	);

=head1 DESCRIPTION

This module works as a wrapper/proxy/bootstrapper for the Net::ACL class.

It makes it possible to B<renew> a list thats has not yet been constructed
using its name and type. The list should be constructed before any method
is used on this object.

=head1 CONSTRUCTOR

I<renew()> - create a new Net::ACL::Bootstrap object:

    $list = renew Net::ACL(
        Name    => 'MyACL',
	Type	=> 'prefix-list',
        );

This is the only constructor for Net::ACL::Bootstrap class.  The arguments
are the same as the B<renew> constructor of the B<Net::ACL> class.

It either returns an existing Net::ACL object matching the arguments or a
reference to the newly created Net::ACL::Bootstrap object.

=head1 ACCESSOR METHODS

I<fetch()>

Forces the class to load the reference to the list or croak if that fails.

I<AUTOLOAD()>

All other methods are proxyed to the real Net::ACL object.

=head1 SEE ALSO

Net::ACL

=head1 AUTHOR

Martin Lorensen <bgp@martin.lorensen.dk>

=cut

## End Package Net::ACL::Bootstrap ##
 
1;
