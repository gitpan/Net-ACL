#!/usr/bin/perl

# $Id: Rule.pm,v 1.8 2003/05/27 23:41:50 unimlo Exp $

package Net::ACL::Rule;

use strict;
use Exporter;
use vars qw(
	$VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS
	@ACL_RC @ACL_ACTION );

## Inheritance and Versioning ##

@ISA     = qw( Exporter );
$VERSION = '0.02';

## Module Imports ##

use Carp;
use Scalar::Util qw( blessed );

## Accesslist Return Codes Constants ##

sub ACL_NOMATCH  {  0; };
sub ACL_MATCH    {  1; };

## Accesslist Action Codes Constants ##

sub ACL_DENY     {  2; };
sub ACL_PERMIT   {  3; };
sub ACL_CONTINUE {  4; };

## Export Tag Definitions ##

@ACL_RC      = qw( ACL_MATCH ACL_NOMATCH );
@ACL_ACTION  = qw( ACL_PERMIT ACL_DENY ACL_CONTINUE );
@EXPORT      = ();
@EXPORT_OK   = ( @ACL_RC, @ACL_ACTION );
%EXPORT_TAGS = (
    rc       => [ @ACL_RC ],
    action   => [ @ACL_ACTION ],
    ALL      => [ @EXPORT, @EXPORT_OK ]
);

## Public Class Methods ##

sub new
{
 my $proto = shift;
 my $class = ref $proto || $proto;

 my $this = {
        _action => ACL_PERMIT,
	_match => [],
	_set => []
  };

 bless($this, $class);

 while ( defined(my $arg = shift) )
  {
   my $value = shift;
   if ( $arg =~ /action/i )
    {
     $value = ACL_PERMIT if $value =~ /permit/i;
     $value = ACL_DENY if $value =~ /deny/i;
     $this->{_action} = $value;
    }
   elsif ( $arg =~ /match/i )
    {
     $this->_handlerules('Match','_match',$value);
    }
   elsif ( $arg =~ /set/i )
    {
     $this->_handlerules('Set','_set',$value);
    }
   else
    {
     croak "Unrecognized argument $arg";
    };
  };

 return $this;
}

sub clone
{
 my $proto = shift;
 my $class = ref $proto || $proto;
 $proto = shift unless ref $proto;

 my $clone;

 $clone->{_action} = $proto->{_action};

 foreach my $key (qw(_set _match ))
  {
   # $clone->{$key} = [ map { $_->clone; } @{$proto->{$key}} ]; # Can't clone!
   $clone->{$key} = [ @{$proto->{$key}} ];
  }

 return ( bless($clone, $class) );
}

## Public Object Methods ##

sub action
{
 my $this = shift;

 $this->{_action} = @_ ? shift : $this->{_action};
 return $this->{_action};
}

sub action_str
{
 my $this = shift;
 $this->{_action} = @_ ? (shift =~ /permit/i ? ACL_PERMIT : ACL_DENY) : $this->{_action};
 return (($this->{_action} == ACL_PERMIT) ? 'permit' : 'deny'); 
}

sub match
{
 my $this = shift;
 foreach my $subrule (@{$this->{_match}})
  {
   return ACL_NOMATCH unless $subrule->match(@_);
  };
 return ACL_MATCH;
}

sub set
{
 my $this = shift;
 foreach my $subrule (@{$this->{_set}})
  {
   @_ = $subrule->set(@_);
  };
 return @_;
}

sub query
{
 my $this = shift;
 return (ACL_CONTINUE,@_) unless $this->match(@_);
 return ($this->{_action},($this->{_action} == ACL_DENY) ? undef : $this->set(@_));
}

sub add_match
{
 shift->_add('_match',@_); 
}

sub remove_match
{
 shift->_remove('_match',@_); 
};

sub add_set
{
 shift->_add('_set',@_); 
}

sub remove_set
{
 shift->_remove('_set',@_); 
};

sub autoconstruction
{
 my ($this,$type,$class,$arg,@value) = @_;
 $class = 'Net::ACL::' . $type . '::' . $arg unless defined $class;
 unless ($class->isa('Net::ACL::'.$type))
  {
   eval "use $class;";
   croak "Unknown $type rule key $arg - No class $class found (Value: @value)." if ($@ =~ /Can't locate/);
   croak $@ if ($@);
   croak "$class is not a Net::ACL::$type class"
     unless $class->isa('Net::ACL::'.$type)
  };
 return $class->new(@value);
}

## Private Object Methods ##

sub _add
{
 my $this = shift;
 my $key = shift;
 push(@{$this->{$key}},@_);
}

sub _remove
{
 my $this = shift;
 my $key = shift;
 my @arg = @_;
 @{$this->{$key}} = grep {
	 foreach my $arg (@arg) { $_ = undef if $arg == $_; };
	} @{$this->{$key}};
}

sub _handlerules
{
 my ($this,$type,$key,$value) = @_;
 croak "$type option can not be a SCALAR" unless ref $value;
 if ((blessed $value) && $value->isa('Net::ACL::' . $type))
  {
   $this->_add($key,$value);
  }
 elsif (ref $value eq 'ARRAY')
  { 
   $this->_add($key,@{$value});
  }
 elsif (ref $value eq 'HASH')
  {
   foreach my $arg (keys %{$value})
    {
     my $subclass = 'Net::ACL::' . $type . '::' . $arg;
     $this->_add($key,$this->autoconstruction($type,$subclass,$arg,$value->{$arg}));
    };
  }
 else
  {
   croak "Unknown $type option value type";
  };
}

## POD ##

=pod

=head1 NAME

Net::ACL::Rule - Class representing a generic access-list/route-map entry

=head1 SYNOPSIS

    use Net::ACL::Rule qw( :action :rc );

    # Constructor
    $entry = new Net::ACL::Rule(
	Action	=> ACL_PERMIT
	Match	=> {
		IP	=> '127.0.0.0/8'
		}
	Set	=> {
		IP	=> '127.0.0.1'
		}
	);
		
    # Object Copy
    $clone = $entry->clone();

    # Accessor Methods
    $action = $entry->action($action);
    $action_str = $entry->action($action_str);

    $entry->add_match($matchrule);
    $entry->remove_match($matchrule);
    $entry->add_set($setrule);
    $entry->remove_set($setrule);

    $rc = $entry->match(@data);
    @data = $entry->set(@data);

    ($rc,@data) = $entry->query(@data);

    $subrule = $entry->autoconstruction($type,$class,$arg,@values);

=head1 DESCRIPTION

This module represent a single generic access-list and route-map entry. It is
used by the B<Net::ACL> object. It can match anydata against a
list of B<Net::ACL::Match> objects, and if all are matched, it
can have a list of B<Net::ACL::Set> objects modify the data.

=head1 CONSTRUCTOR

I<new()> - create a new Net::ACL::Rule object

    $entry = new Net::ACL::Rule(
        Action  => ACL_PERMIT
	Match	=> {
		IP	=> '127.0.0.0/8'
		}
	Set	=> {
		IP	=> '127.0.0.1'
		}
	);
		
This is the constructor for Net::ACL::Rule objects. It returns a
reference to the newly created object. The following named parameters may
be passed to the constructor.

=head2 Action

The action parameter could be either of the constants exported using "action"
(See B<EXPORTS>) or just a string matching permit or deny. ACL_PERMIT accepts
the data, ACL_DENY drops the data, while ACL_CONTINUE is used to indicate that
this entry might change the data, but does not decide whether the data should
be accepted or droped.

=head2 Match

The match parameter can have multiple forms, and my exists zero, one or more
times. The following forms are allowed:

B<Match object> - A B<Net::ACL::Match> object (or ancestor)

B<List> - A list of B<Net::ACL::Match> objects (or ancestors)

B<Hash> - A hash reference. The constructor will for each ($key,$value) pair
call the B<autoconstructor> method and add the returned objects to the
rule-set.

=head2 Set

The set parameter are in syntaks just like the B<Match> parameter, except
it uses B<Net::ACL::Set> objects.

=head1 OBJECT COPY

I<clone()> - clone a Net::ACL::Rule object

    $clone = $entry->clone();

This method creates an exact copy of the Net::ACL::Rule object,
with set, match and action attributes.

=head1 ACCESSOR METHODS

I<action()>

This method returns the entry's action value. If called with an argument,
the action value are changed to that argument.

I<action_str()>

This method returns the entry's action string as either 'permit' or 'deny'.
If called with an argument, the action value are changed to ACL_PERMIT if
the argument matches /permit/i - otherwise ACL_DENY.

I<add_match()>

I<remove_match()>

I<add_set()>

I<remove_set()>

The methods adds and removes match and set rules. Each argument should be a
match or set rule object. New rules are added in the end of the ruleset.

I<match()>

The match method get any abitrary number of arguments. The arguments are passed
to the B<match> method of each of the B<Net::ACL::Match> objects,
given at construction time (See B<CONSTROCTOR>). If all Match objects did
match, the method returns ACL_MATCH. Otherwise ACL_MATCH.

I<set()>

The set method get any abitrary number of arguments. The arguments are passed
to the first of the B<Net::ACL::Set> objects B<set> method. The
result of this function is then used to call the next. This is repeated for
all Set objects given at construction time (See B<CONSTRUCTOR> section).
Finaly the result of the last call is returned.

I<query()>

The query method first attempt to B<match> it's arguments with the match
method. If this failes, it returns ACL_CONTINUE. Otherwise it uses
the B<set> method to potentialy alter the arguments before they are returned
with B<Action> given on construction prefixed.

I<autoconstruction()>

This method is used on construction to construct rules based on
(key,value)-pairs in a Rule argument hash reference.

The first argument is the type (Match or Set). The second is the class name
(see below). The third is the key name from the construction hash. The forth
and if any, the rest of the arguments, are used as parameters to the
constructor.

The return value will be the result of:

	$class->new(@values);

The class is by the constructor set as "Net::ACL::$type::$key"

B<NOTE>: Do to this, the keys of the hash are case-sensetive!

By replacing this function in a sub-class, it is posible to modify the class
and/or key-value pairs and hence make more complex constructions from simple
key-value pairs, or have more user-friendly key values (e.g. make them
case-insensetive).

=head1 EXPORTS

The module exports the following symbols according to the rules and
conventions of the B<Exporter> module.

=head2 :rc

	ACL_MATCH, ACL_NOMATCH

=head2 :action

	ACL_PERMIT, ACL_DENY, ACL_CONTINUE

=head1 SEE ALSO

B<Net::ACL>, B<Net::ACL::Set>, B<Net::ACL::Match>

=head1 AUTHOR

Martin Lorensen <bgp@martin.lorensen.dk>

=cut

## End Package Net::ACL::Rule ##
 
1;
