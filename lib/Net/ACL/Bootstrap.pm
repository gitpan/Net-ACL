#!/usr/bin/perl

# $Id: Bootstrap.pm,v 1.7 2003/05/28 14:38:59 unimlo Exp $

package Net::ACL::Bootstrap;

use strict;
use vars qw( $VERSION @ISA $AUTOLOAD );

## Inheritance and Versioning ##

@ISA     = qw( Exporter );
$VERSION = '0.03';

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

sub name
{
 my $this = shift;
 $this->fetch unless defined $this->{_reallist};
 return $this->{_reallist}->name(@_) if defined $this->{_reallist};
 # Modification is too odd!
 return $this->{_name};
}

sub type
{
 my $this = shift;
 $this->fetch unless defined $this->{_reallist};
 return $this->{_reallist}->type(@_) if defined $this->{_reallist};
 # Modification is too odd!
 return $this->{_type};
}

sub AUTOLOAD
{
 my $method = $AUTOLOAD;
 my $this = shift;
 my $class = ref $this || $this;
 $method =~ s/${class}:://;
 $this->fetch unless defined $this->{_reallist};
 croak "Match with non-existing access-list!\n" unless defined $this->{_reallist};
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
}

## POD ##

=pod

=head1 NAME

Net::ACL::Bootstrap - A proxy/bootstrapper class for the L<Net::ACL|Net::ACL> class

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
using its name and type. The real list should be constructed before any
method is used on this object (except name(), type() and fetch()).

=head1 CONSTRUCTOR

=over 4

=item renew() - create a new Net::ACL::Bootstrap object:

    $list = renew Net::ACL(
        Name    => 'MyACL',
	Type	=> 'prefix-list',
        );

This is the only constructor for Net::ACL::Bootstrap class.  The arguments
are the same as the B<renew> constructor of the Net::ACL class.

It either returns an existing Net::ACL object matching the arguments or a
reference to the newly created Net::ACL::Bootstrap object.

=back

=head1 ACCESSOR METHODS

=over 4

=item fetch()

Forces the class to load the reference to the list or croak if that fails.

=item name()

=item type()

It is possible to query name and type data of the list, however, not to
change them, unless the list is loaded. But only if the list can be loaded,
change the name or type can be done.

=item AUTOLOAD()

All other methods are proxyed to the real Net::ACL object.

=back

=head1 SEE ALSO

Net::ACL

=head1 AUTHOR

Martin Lorensen <bgp@martin.lorensen.dk>

=cut

## End Package Net::ACL::Bootstrap ##
 
1;
