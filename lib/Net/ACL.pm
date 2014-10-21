#!/usr/bin/perl

# $Id: ACL.pm,v 1.8 2003/05/27 23:41:48 unimlo Exp $

package Net::ACL;

use strict;
use vars qw( $VERSION @ISA );

## Inheritance and Versioning ##

@ISA     = qw( Exporter );
$VERSION = '0.02';

## Module Imports ##

use Carp;
use Net::ACL::Rule qw( :action );
use Scalar::Util qw( weaken blessed );

## Global Private Variables ##

my %knownlists;

## Public Class Methods ##

sub new
{
 my $proto = shift;
 my $class = ref $proto || $proto;

 my $this = {
        _name => undef,
	_type => undef,
	_rules => []
  };

 while ( defined(my $arg = shift) )
  {
   my $value = shift;
   if ( $arg =~ /name/i )
    {
     $this->{_name} = $value;
    }
   elsif ( $arg =~ /type/i )
    {
     $this->{_type} = $value;
    }
   elsif ( $arg =~ /rule/i )
    {
     croak "Rule option can not be a SCALAR" unless ref $value;
     if ((blessed $value) && $value->isa('Net::ACL::Rule'))
      {
       push(@{$this->{_rules}},$value);
      }
     elsif (ref $value eq 'ARRAY')
      { 
       push(@{$this->{_rules}},@{$value});
      }
     elsif (ref $value eq 'HASH')
      {
       push(@{$this->{_rules}},@{$value}{sort { $a <=> $b } keys %{$value}});
      }
     else
      {
       croak "Unknown rule option value type";
      };
    }
   else
    {
     croak "Unrecognized argument $arg";
    };
  };

 bless($this, $class);

 croak 'Two access-lists with same (type,name) identification are not allowed!'
	if defined $this->{_name} && defined $knownlists{$this->{_type} || $class}->{$this->{_name}};
 weaken($knownlists{_hash}->{$this} = $this);
 weaken($knownlists{$this->{_type} || $class}->{$this->{_name}} = $this)
	if defined $this->{_name};

 return $this;
}

sub renew
{
 my $proto = shift;
 my $class = ref $proto || $proto;
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
     return $knownlists{_hash}->{$arg};
    };
  };
 return $knownlists{$type}->{$name};
}

sub clone
{
 my $proto = shift;
 my $class = ref $proto || $proto;
 $proto = shift unless ref $proto;

 my $clone;
 $clone->{_name} = undef; # Not the same name!
 $clone->{_type} = $proto->{_type}; # Still same type!

 $clone->{_rules} = [ map { $_->clone; } @{$proto->{_rules}} ];

 bless($clone, $class);

 weaken($knownlists{_hash}->{$clone} = $clone);

 return $clone;
}

sub knownlists
{
 my $proto = shift;
 my $class = ref $proto || $proto;
 my %res;
 foreach my $key (keys %knownlists)
  {
   $res{$key} = [ keys %{$knownlists{$key}} ];
  };
 return \%res;
}

sub DESTROY
{
 my $this = shift;
 $this->name(undef);
 $this->type(undef);
 delete $knownlists{_hash}->{$this};
}

## Public Object Methods ##

sub name
{
 my $this = shift;
 my $class = ref $this;

 if (@_)
  {
   my $newname = shift;

   return $this->{_name} # Don't do anything if name not changed!
	unless (defined $newname || defined $this->{_name})
	 && ! (defined $newname && defined $this->{_name} && $newname eq $this->{_name});

   croak 'Two access-lists with same (type,name) = (' .
	($this->{_type} || $class) . ',' . $newname . ') identification are not allowed!'
		if defined $newname
		&& defined $knownlists{$this->{_type} || $class}->{$newname};

   # Change name!
   delete $knownlists{$this->{_type} || $class}->{$this->{_name}} if defined $this->{_name};
   $this->{_name} = $newname;
   weaken($knownlists{$this->{_type} || $class}->{$this->{_name}} = $this)
	if defined $this->{_name};
  };

 return $this->{_name};
}

sub type
{
 my $this = shift;
 my $class = ref $this;

 if (@_)
  {
   my $newtype = shift;
   return $this->{_type} # Don't do anything if type hasn't changed!
	unless (defined $newtype || defined $this->{_type})
	 && ! (defined $newtype && defined $this->{_type} && $newtype eq $this->{_type});

   croak 'Two access-lists with same (type,name) = (' .
	($this->{_type} || $class) . ',' . $this->{_name} . ') identification are not allowed!'
		if defined $this->{_name}
		&& $knownlists{$newtype || $class}->{$this->{_name}};
   delete $knownlists{$this->{_type} || $class}->{$this->{_name}}
	if defined $this->{_name};
   $this->{_type} = $newtype;
   weaken($knownlists{$this->{_type} || $class}->{$this->{_name}} = $this)
	if defined $this->{_name};
  };

 return $this->{_type};
}

sub add_rule
{
 my $this = shift;
 push(@{$this->{_rules}},@_);
}

sub remove_rule
{
 my $this = shift;
 my @arg = @_;
 @{$this->{_rules}} = grep {
         foreach my $arg (@arg) { $_ = undef if $arg == $_; };
        } @{$this->{_rules}};
}

sub match
{
 my $this = shift;
 my @data = @_;
 return ACL_PERMIT unless scalar @{$this->{_rules}}; # No rules!
 foreach my $rule (@{$this->{_rules}})
  {
   next if $rule->action == ACL_CONTINUE;
   return $rule->action if $rule->match(@data);
  };
 return ACL_DENY; # No match - implicit deny!
}

sub query
{
 my $this = shift;
 my @data = @_;
 return (ACL_PERMIT,undef) unless scalar @{$this->{_rules}}; # No rules! Implicit permit
 foreach my $rule (@{$this->{_rules}})
  {
   my $rc;
   ($rc,@data) = $rule->query(@data);
   return ($rc,@data) unless $rc == ACL_CONTINUE;
  };
 return (ACL_DENY,undef); # No match - implicit deny!
}

## POD ##

=pod

=head1 NAME

Net::ACL - Class representing a generic access-list/route-map

=head1 SYNOPSIS

    use Net::ACL;
    use Net::ACL::Rule qw( :action :rc );

    # Constructor
    $list = new Net::ACL(
	Name    => 'MyACL',
	Type	=> 'prefix-list',
	Rule	=> new Net::ACL::Rule( .. )
	);

    # Fetch existing object by name
    $list = renew Net::ACL(
	Name	=> 'MyACL'
	Type	=> 'prefix-list'
	);
    $list = renew Net::ACL("$list");

    # Object Copy
    $clone = $list->clone();

    # Class methods
    $type_names_hr = Net::ACL->knownlists();

    # Accessor Methods
    $list->add_rule($rule);
    $list->remove_rule($rule);
    $name = $list->name($name);
    $type = $list->type($type);
    $rc = $list->match(@data);
    ($rc,@data) = $list->query(@data);

=head1 DESCRIPTION

This module represent a generic access-list and route-map. It uses the
B<Net::ACL::Rule> object to represent the rules.

=head1 CONSTRUCTOR

I<new()> - create a new Net::ACL object

    $list = new Net::ACL(
        Name    => 'MyACL',
	Type	=> 'prefix-list',
        Rule    => new Net::ACL::Rule( .. )
        );

This is the constructor for Net::ACL objects. It returns a
reference to the newly created object. The following named parameters may
be passed to the constructor.

=head2 Name

The name parameter is optional and is only used to identify a list by the
B<renew> constructor.

=head2 Type

The type parameter is optional and defaults to the class name. It is used
have different namespaces for the B<Name> parameter. It is intended to have
values like 'ip-accesslist', 'prefix-list', 'as-path-filter' and 'route-map'.
This way the same name or number of an accesslist could be reused in each
class.

=head2 Rule

The rule parameter could be pressent one or more times. Each one can have
mulitple types:

B<Net::ACL::Rule> - A Net::ACL::Rule object.

B<ARRAY> - An array reference of Net::ACL::Rule objects.

B<HASH> - A hash reference with Net::ACL:Rule objects as values. Keys are
currently ignored, but might later be used as sequance numbers or labels.

I<renew()> - fetch an existing Net::ACL object

    $list = renew Net::ACL(
	Name	=> 'MyACL'
	Type	=> 'prefix-list'
	);
    $list = renew Net::ACL("$list");

The renew constructor localizes an existing ACL object from either
Name, (Name,Type)-pair or the object in string context (e.g.
I<Net::ACL=HASH(0x823ff84)>). The Name and Yype arguments
have simular meaning as for the B<new> constructor.

=head1 OBJECT COPY

I<clone()> - clone a Net::ACL object

    $clone = $list->clone();

This method creates an exact copy of the Net::ACL object and all
the rules. The clone will not have a name unless one is assigned explicitly
later.

=head1 ACCESSOR METHODS

I<name()>

I<type()>

The name and type methods returns the access-list name and type fields
respectivly. If called with an argument they change the value to that of the
argument.

I<match()>

The match method implements the basic idear of a stadard router access-list
matching.

It get any abitrary number of arguments. The arguments are passed
to the B<match> method of each of the B<Net::ACL::Rule> rules
except any object which have the B<Action> field set to ACL_CONTINUE.
When a B<match> method returns ACL_MATCH, the B<Action> of that
entry is returned.

I<query()>

The query method implements the basic idear of a route-map execution.

It calls the B<Net::ACL::Rule> rules B<query> method
one by one as long as they return ACL_CONTINUE.

The function returns the result code (ACL_PERMIT or ACL_DENY)
and the, posibly modified, arguments of the function.

I<add_rule()>

I<remove_rule()>

The add and remove rule methods can add and remove rules after object
construction.

=head1 SEE ALSO

Net::ACL::Rule, Net::ACL::File, Net::ACL::Bootstrap

=head1 AUTHOR

Martin Lorensen <bgp@martin.lorensen.dk>

=cut

## End Package Net::ACL ##
 
1;
