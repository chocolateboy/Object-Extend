# Object::Extend

[![Build Status](https://github.com/chocolateboy/Object-Extend/workflows/test/badge.svg)](https://github.com/chocolateboy/Object-Extend/actions?query=workflow%3Atest)
[![CPAN Version](https://badge.fury.io/pl/Object-Extend.svg)](https://badge.fury.io/pl/Object-Extend)

<!-- TOC -->

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

<!-- TOC END -->

# NAME

Object::Extend - add and override per-object methods

# SYNOPSIS

```perl
use Object::Extend qw(extend);

my $foo1 = Foo->new;
my $foo2 = Foo->new;

extend $foo1 => {
    bar => sub { ... },
};

$foo1->bar; # OK
$foo2->bar; # error
```

# DESCRIPTION

This module allows objects to be extended with per-object methods, similar to
the use of [singleton methods](https://web.archive.org/web/20160319051340/http://madebydna.com/all/code/2011/06/24/eigenclasses-demystified.html)
in Ruby. Object methods are added to an object-specific shim class (known as an
`eigenclass`), which extends the object's original class. The original class is
left unchanged.

# EXPORTS

## extend

`extend` takes an object and a hash or hashref of method names and method
values (coderefs) and adds the methods to the object's shim class. The object
is then blessed into this class and returned.

It can be used in standalone statements:

```perl
extend $object, foo => sub { ... }, bar => \&bar;
```

Or expressions:

```perl
return extend($object => { bar => sub { ... } })->bar;
```

In both cases, `extend` operates on and returns the supplied object, i.e. a new
object is never created. If a new object is needed, it can be created manually,
e.g.:

```perl
my $object2 = Object->new($object1);
my $object3 = clone($object1);

extend($object2, foo => sub { ... })->foo;
return extend($object3 => ...);
```

Objects can be extended multiple times with new or overridden methods:

```perl
# call the original method
my $object = Foo->new;
$object->foo;

# override the original method
extend $object, foo => sub { ... };
$object->foo;

# add a new method
extend $object, bar => sub { ... };
$object->bar;
```

## with

This sub can optionally be imported to make the use of `extend` more
descriptive. It takes and returns a hashref of method names/coderefs:

```perl
use Object::Extend qw(extend with);

extend $object => with { foo => sub { ... } };
```

## SINGLETON

Every extended object's shim class includes an additional (empty) class in its
`@ISA` which indicates that the object has been extended. The name of this
class can be accessed by importing the `SINGLETON` constant, e.g.:

```perl
use Object::Extend qw(SINGLETON);

if ($object->isa(SINGLETON)) { ... } # object extended with object-specific methods
```

# VERSION

0.4.0

# SEE ALSO

- [Class::Monadic](https://metacpan.org/pod/Class::Monadic)
- [Class::SingletonMethod](https://metacpan.org/pod/Class::SingletonMethod)
- [MooseX::SingletonMethod](https://metacpan.org/pod/MooseX::SingletonMethod)
- [MouseX::SingletonMethod](https://metacpan.org/pod/MouseX::SingletonMethod)
- [Object::Accessor](https://metacpan.org/pod/Object::Accessor)
- [SingletonMethod](https://github.com/tom-lpsd/p5-singleton-method)

# AUTHOR

[chocolateboy](mailto:chocolate@cpan.org)

# COPYRIGHT AND LICENSE

Copyright © 2013-2021 by chocolateboy.

This is free software; you can redistribute it and/or modify it under the terms of the
[Artistic License 2.0](https://www.opensource.org/licenses/artistic-license-2.0.php).
