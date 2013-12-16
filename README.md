# Object::Extend

- [NAME](#name)
- [SYNOPSIS](#synopsis)
- [DESCRIPTION](#description)
    - [EXPORTS](#exports)
        - [extend](#extend)
        - [with](#with)
        - [SINGLETON](#singleton)
- [VERSION](#version)
- [SEE ALSO](#see-also)
- [AUTHOR](#author)
- [COPYRIGHT AND LICENSE](#copyright-and-license)

## NAME

Object::Extend - add and override per-object methods

## SYNOPSIS

    use Object::Extend qw(extend);

    my $foo1 = Foo->new;
    my $foo2 = Foo->new;

    extend $foo1 => {
        bar => sub { ... },
    };

    $foo1->bar; # OK
    $foo2->bar; # error

## DESCRIPTION

This module allows objects to be extended with per-object methods, similar to the use of
[singleton methods](http://madebydna.com/all/code/2011/06/24/eigenclasses-demystified.html)
in Ruby. Object methods are added to an object-specific shim class (known as an `eigenclass`),
which extends the object's original class. The original class is left unchanged.

### EXPORTS

#### extend

`extend` takes an object and a hash or hashref of method names and method values (coderefs) and adds
the methods to the object's shim class. The object is then blessed into this class and returned.

It can be used in standalone statements:

    extend $object, foo => sub { ... }, bar => \&bar;

Or expressions:

    return extend($object => { bar => sub { ... } })->bar;

In both cases, `extend` operates on and returns the supplied object i.e. a new object is never created.
If a new object is needed, it can be created manually e.g.:

    my $object2 = Object->new($object1);
    my $object3 = clone($object1);

    extend($object2, foo => sub { ... })->foo;
    return extend($object3 => ...);

Objects can be extended multiple times with new or overridden methods:

    # call the original method
    my $object = Foo->new;
    $object->foo;

    # override the original method
    extend $object, foo => sub { ... };
    $object->foo;

    # add a new method
    extend $object, bar => sub { ... };
    $object->bar;

#### with

This sub can optionally be imported to make the use of `extend` more descriptive. It takes and
returns a hashref of method names/coderefs:

    use Object::Extend qw(extend with);

    extend $object => with { foo => sub { ... } };

#### SINGLETON

Every extended object's shim class includes an additional (empty) class in its `@ISA` which indicates
that the object has been extended. The name of this class can be accessed by importing the `SINGLETON`
constant e.g.:

    use Object::Extend qw(SINGLETON);

    if ($object->isa(SINGLETON)) { ... } # object extended with object-specific methods

## VERSION

0.4.0

## SEE ALSO

- [Class::Monadic](http://search.cpan.org/perldoc?Class::Monadic)
- [Class::SingletonMethod](http://search.cpan.org/perldoc?Class::SingletonMethod)
- [MooseX::SingletonMethod](http://search.cpan.org/perldoc?MooseX::SingletonMethod)
- [MouseX::SingletonMethod](http://search.cpan.org/perldoc?MouseX::SingletonMethod)
- [Object::Accessor](http://search.cpan.org/perldoc?Object::Accessor)
- [SingletonMethod](https://github.com/tom-lpsd/p5-singleton-method)

## AUTHOR

chocolateboy

## COPYRIGHT AND LICENSE

Copyright (C) 2013 by chocolateboy

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.
