# NAME

Object::Extend - add or override per-object methods

# SYNOPSIS

    use Object::Extend qw(extend);

    my $foo1 = Foo->new;
    my $foo2 = Foo->new;

    extend $foo2 => {
        bar => sub { ... },
    };

    $foo1->bar; # error
    $foo2->bar; # OK

# DESCRIPTION

This module allows Ruby (and JavaScript) style "singleton methods" to be added to Perl objects.
Singleton methods are added to an object-specific shim class (the object's `eigenclass`) which
extends the object's original class. The original class is left unchanged.

For more details on singleton methods, see here: http://madebydna.com/all/code/2011/06/24/eigenclasses-demystified.html

## EXPORT

### extend

`extend` takes an object and a hash or hashref of method names and method values (coderefs) and adds
the methods to the object's eigenclass. The object is then blessed into the eigenclass and returned.

It can be used in standalone statements:

    extend $object, foo => sub { ... }, bar => \&bar;

Or expressions:

    return extend($object => { bar => sub { ... } })->bar;

In both cases, `extend` operates on and returns the supplied object i.e. a new object is never created.
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

### with

This sub can optionally be imported to make the use of `extend` more descriptive. It takes and
returns a hashref of method names/coderefs:

    use Object::Extend qw(extend with);

    extend $object => with { foo => sub { ... } };

## METHODS

### EIGENCLASS

Every extended object's eigenclass includes an additional class in its `@ISA` which indicates
that the object has been extended. This class name is accessible via the `EIGENCLASS` method e.g.:

    if ($object->isa(Object::Extend->EIGENCLASS)) { ... } # object extended with object-specific methods

# VERSION

0.0.1

# SEE ALSO

- [Class::SingletonMethod](http://search.cpan.org/perldoc?Class::SingletonMethod)
- [MooseX::SingletonMethod](http://search.cpan.org/perldoc?MooseX::SingletonMethod)
- [MouseX::SingletonMethod](http://search.cpan.org/perldoc?MouseX::SingletonMethod)

# AUTHOR

chocolateboy <chocolate@cpan.org>

# COPYRIGHT AND LICENSE

Copyright (C) 2013 by chocolateboy

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.
