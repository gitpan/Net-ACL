#!/usr/bin/perl

# $Id: File.pm,v 1.4 2003/05/27 02:08:56 unimlo Exp $

package Net::ACL::File;

use strict;
use vars qw( $VERSION @ISA );
use Carp;

## Inheritance and Versioning ##

@ISA     = qw( Exporter Net::ACL );
$VERSION = '0.01';

## Module Imports ##

use Net::ACL;
use Net::ACL::Rule qw( :rc :action );
use Carp;
use Cisco::Reconfig;

## Private Global Class Variables ##

my %knownlists;

## Public Class Methods ##

sub add_knownlist
{
 my $proto = shift;
 my $class = ref $proto || $proto;
 my ($type,$aclclass,$match,$use) = @_;
 $use ||= $aclclass;
 $match ||= $type;
 unless ($aclclass->isa('Net::ACL::File::Standard'))
  {
   eval "use $use;";
   croak "Error adding $match ($type) - Can't locate $use module." if ($@ =~ /Can't locate/); 
   croak $@ if ($@);
   croak "$aclclass is not a Net::ACL::File::Standard class"
	unless ($aclclass->isa('Net::ACL::File::Standard'))
  };
 $knownlists{$match}->{_class} = $aclclass;
 $knownlists{$match}->{_type} = $type;
}

sub load
{
 my $proto = shift;
 my $class = ref $proto || $proto;
 my $obj = shift;
 unless ((ref $obj) && $obj->isa('Cisco::Reconfig'))
  {
   $obj = Cisco::Reconfig::stringconfig($obj);
   croak "Unable to load configuration data" unless $obj;
  };

 my $res;

 foreach my $match (keys %knownlists)
  {
   my $aclclass = $knownlists{$match}->{_class};
   my $lists = $obj->get($match);
   foreach my $list ($lists->single ? $lists : $lists->get)
    {
     next if $list->text eq '';
     my $acl = $aclclass->load($list);
     $acl->type($knownlists{$match}->{_type});
     $res->{$acl->type}->{$acl->name} = $acl;
    }
  };

 return $res;
}

## Public Object Methods ##

sub asconfig
{
 my $this = shift;
 my $class = ref $this || $this;
 $this = shift if $this eq $class;

 my $conf = '';
 croak 'ACL need name for configuration to be generated' unless defined $this->name;
 croak 'ACL need type for configuration to be generated' unless defined $this->type;
 foreach my $rule (@{$this->{_rules}})
  {
   croak "ACL rule of class " . (ref $rule) . " has no asconfig method!" unless $rule->can('asconfig');
   $conf .= $rule->asconfig($this->name,$this->type);
  };
 return $conf;
}

## POD ##

=pod

=head1 NAME

Net::ACL::File - Access-lists constructed from configuration file like syntax.

=head1 SYNOPSIS

    use Net::ACL::File;

    # Construction
    $config = 'ip community-list 4 permit 65001:1¨;
    $list_hr = load Net::ACL::File($config);

    Net::ACL::File->add_knownlist('community-list', __PACKAGE__,'ip community-list');

    $list = renew Net::ACL(Type => 'community-list', Name => 4);
    $config2 = $list->asconfig; # $config2 =~ /$config/;

=head1 DESCRIPTION

This module extends the Net::ACL class with a load constructor that loads one
or more objects from a cisco-like configuration file using B<Cisco::Reconfig>.

=head1 CONSTRUCTOR

    $list_hr = load Net::ACL::File($config);

This special constructor parses a cisco-like router configuration.

The constructor takes one argument which should either be a string or a
B<Cisco::Reconfig> object.

It returns a hash reference. The hash is indexed on
list-types. Currently supporting the following:

I<community-list>, I<as-path-list>, I<prefix-list>, I<access-list>

Each list-type hash value conains a new hash reference indexed on list names
or numbers.

=head1 CLASS METHODS

I<add_knownlist()>

The add_knownlist class method registers a new class of access-lists.

The first argument is the type-string of the new class.
The second argument is the class to be registered. The class should be a
sub-class of Net::BGP::File::Standard. Normaly this should be '__PACKAGE__'.

The third argument is used to match the lines in the configuration file using
B<Cisco::Reconfig>'s B<all(REGEXP)> method. If match argument is not defined,
the type string will be used.

The forth argument is used to load the class with a "use" statement. This
should only be needed if the class is located in a different package.
Default is the class name from the second argument.

=head1 ACCESSOR METHODS

I<asconfig()>

This function tries to generate a configuration matching the one the load
constructer got. It can read from any access-list. The resulting configuration
is returned as a string.

All ACL's which rules supports the I<asconfig> method may be used. To do so,
use:

	$conf = Net::ACL::File->asconfig($acl);

=head1 SEE ALSO

B<Net::ACL>, B<Cisco::Reconfig>, B<Net::ACL::File>

=head1 AUTHOR

Martin Lorensen <bgp@martin.lorensen.dk>

=cut

## End Package Net::ACL::File ##

1;
