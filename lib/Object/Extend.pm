package Object::Extend;

use 5.006;
use strict;
use warnings;
use base qw(Exporter);
use constant EIGENCLASS => sprintf('%s::_Eigenclass', __PACKAGE__);

our @EXPORT_OK = qw(extend with);
our $VERSION = '0.0.1';

# given an object, return an object-specific class name
sub _eigenclass($) {
    sprintf '%s::_%0x', EIGENCLASS, $_[0];
}

# install the supplied sub in the the supplied class.
# "extend" is a pretty clear statement of intent, so
# we don't issue a warning if the sub already exists
sub _install_sub($$) {
    my ($class, $sub) = @_;
    no strict 'refs';
    no warnings 'redefine';
    *$class = $sub;
}

# set a class's @ISA array
sub _set_isa($$) {
    my ($class, $isa) = @_;
    no strict 'refs';
    *{"$class\::ISA"} = $isa;
}

# helper sub to optionally make the syntax
# a bit more DSL-ish: extend $object => with ...
sub with($) { $_[0] }

# for regular (unextended) objects, a) create an object-specific class
# (eigenclass) b) set its @ISA to [ ref($object), EIGENCLASS ] and
# c) bless the object into this new class.
#
# if an object has already been extended, add the supplied
# methods to its eigenclass.
#
# Note the EIGENCLASS class added to the eigenclass's @ISA doesn't
# implement any methods: we just use it as metadata to indicate that
# the object has already been extended.
sub extend($;@) {
    my $object = shift;
    my $methods = @_ == 1 ? shift : { @_ };
    my $eigenclass = _eigenclass($object);

    unless ($object->isa(EIGENCLASS)) {
        _set_isa($eigenclass, [ ref($object), EIGENCLASS ]);
        bless $object, $eigenclass;
    }

    while (my ($name, $sub) = each(%$methods)) {
        _install_sub("$eigenclass\::$name", $sub);
    }

    return $object;
}

1;

=head1 NAME

Object::Extend - add or override per-object methods

=head1 SYNOPSIS

    use Object::Extend qw(extend);

    my $foo1 = Foo->new;
    my $foo2 = Foo->new;

    extend $foo2 => {
        bar => sub { ... },
    };

    $foo1->bar; # error
    $foo2->bar; # OK

=head1 DESCRIPTION

This module allows Ruby (and JavaScript) style "singleton methods" to be added to Perl objects.
Singleton methods are added to an object-specific shim class (the object's C<eigenclass>) which
extends the object's original class. The original class is left unchanged.

For more details on singleton methods, see here: http://madebydna.com/all/code/2011/06/24/eigenclasses-demystified.html

=head2 EXPORT

=head3 extend

C<extend> takes an object and a hash or hashref of method names and method values (coderefs) and adds
the methods to the object's eigenclass. The object is then blessed into the eigenclass and returned.

It can be used in standalone statements:

    extend $object, foo => sub { ... }, bar => \&bar;

Or expressions:

    return extend($object => { bar => sub { ... } })->bar;

In both cases, C<extend> operates on and returns the supplied object i.e. a new object is never created.
If a new object is needed it can be handled manually e.g.:

    my $object2 = Object->new($object1);
    my $object3 = clone($object1);

    extend($object2, foo => sub { ... })->foo;
    return extend($object3 => ...);

Objects can be extended multiple times with the same or different methods:

    my $object = Foo->new;

    # call the original method
    $object->foo;

    # override the original method
    extend $object => foo => sub { ... };
    $object->foo;

    # add a new method
    extend $object => bar => sub { ... };
    $object->bar;

=head3 with

This sub can optionally be imported to make the use of C<extend> more descriptive. It takes and
returns a hashref of method names/coderefs:

    use Object::Extend qw(extend with);

    extend $object => with { foo => sub { ... } };

=head2 METHODS

=head3 EIGENCLASS

Every extended object's eigenclass includes an additional class in its C<@ISA> which indicates
that the object has been extended. This class name is accessible via the C<EIGENCLASS> method e.g.:

    if ($object->isa(Object::Extend->EIGENCLASS)) { ... } # object extended with object-specific methods

=head1 SEE ALSO

=over

=item * L<Class::SingletonMethod|Class::SingletonMethod>

=item * L<MooseX::SingletonMethod|MooseX::SingletonMethod>

=item * L<MouseX::SingletonMethod|MouseX::SingletonMethod>

=back

=head1 AUTHOR

chocolateboy <chocolate@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by chocolateboy

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.

=cut
