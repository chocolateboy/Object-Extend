#!/usr/bin/env perl

use strict;
use warnings;

use constant BAZ_QUUX => {
    baz  => sub { 'Baz' },
    quux => sub { 'Quux' }
};

use Scalar::Util qw(refaddr);
use Test::More tests => 113;

# do this at compile time so that we don't get
# "Useless use of anonymous hash ({}) in void context"
# warnings
BEGIN { use_ok 'Object::Extend' => qw(extend with) }

# try to break things with operator overloading: we need to
# make sure these don't confuse the code that assigns each
# object a unique class name
use overload '+' => \&add, '0+' => \&num, '""' => \&str;

sub add { 42 }
sub num { 42 }
sub str { '42' }

# built-in methods for this class
sub foo { 'Foo' }
sub bar { 'Bar' }

# test helper
sub check_methods($;$) {
    my ($object, $extended) = @_;

    # report errors with caller's line number
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    isa_ok $object, __PACKAGE__;
    is $object->foo, 'Foo';
    is $object->bar, 'Bar';

    if ($extended) {
        isnt ref($object), __PACKAGE__;
        isa_ok $object, Object::Extend->EIGENCLASS;
        is $object->baz, 'Baz';
        is $object->quux, 'Quux';
    } else {
        is ref($object), __PACKAGE__;
        ok !$object->isa(Object::Extend->EIGENCLASS);
        ok !$object->can('baz');
        ok !$object->can('quux');
    }
}

# setup
my $object1 = bless {};
my $object1_refaddr = refaddr($object1);
check_methods($object1);

# add some methods
extend $object1 => BAZ_QUUX;
check_methods($object1, 1);
my $object1_eigenclass = ref($object1);
ok refaddr($object1) == $object1_refaddr;

# make sure there's no change (and no error) when adding
# the same methods
extend $object1 => BAZ_QUUX;
check_methods($object1, 1);
is ref($object1), $object1_eigenclass;
ok refaddr($object1) == $object1_refaddr;

# confirm that the eigenclass is the same if we add a new method
# to an already extended object
extend $object1 => { %{ BAZ_QUUX() }, extra => sub { 'Extra' } };
check_methods($object1, 1);
is ref($object1), $object1_eigenclass;
ok refaddr($object1) == $object1_refaddr;
is $object1->extra, 'Extra';

# confirm that the value returned is the supplied object
my $object2 = bless {};
my $object2_refaddr = refaddr($object2);
check_methods($object2);
my $object3 = extend $object2 => BAZ_QUUX;
check_methods($object3, 1);
ok refaddr($object3) == $object2_refaddr;

# make sure extend $object => with { ... } works
my $object4 = bless {};
my $object4_refaddr = refaddr($object4);
check_methods($object4);
extend $object4 => with BAZ_QUUX;
check_methods($object4, 1);
ok refaddr($object4) == $object4_refaddr;

# confirm that extend works if methods are supplied as
# key/value pairs rather than a hashref
my $object5 = bless {};
my $object5_refaddr = refaddr($object5);
check_methods($object5);
extend $object5 => %{ BAZ_QUUX() };
check_methods($object5, 1);
ok refaddr($object5) == $object5_refaddr;

# make sure the eigenclass uniquely identifies the object:
# it shouldn't be fooled by overloading
my $object6 = bless {};
my $object7 =  bless {};
my $object6_refaddr = refaddr($object6);
my $object7_refaddr = refaddr($object7);
isnt $object6_refaddr, $object7_refaddr;
check_methods($object6);
check_methods($object7);
extend $object6 => BAZ_QUUX;
extend $object7 => BAZ_QUUX;
check_methods($object6, 1);
check_methods($object7, 1);
ok refaddr($object6) == $object6_refaddr;
ok refaddr($object7) == $object7_refaddr;
ok refaddr($object6) != refaddr($object7);
isnt ref($object6), ref($object7); # different eigenclasses
