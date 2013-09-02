#!/usr/bin/env perl

use strict;
use warnings;

use constant BAZ_QUUX => {
    baz  => sub { 'Baz' },
    quux => sub { 'Quux' }
};

use Test::More tests => 80;

# do this at compile time so that we don't get
# "Useless use of anonymous hash ({}) in void context"
# warnings
BEGIN { use_ok 'Object::Extend' => qw(extend with) }

sub foo { 'Foo' }
sub bar { 'Bar' }

sub check_methods($;$) {
    my ($object, $extended) = @_;

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
my $object1_refaddr = int($object1);
check_methods($object1);

# add some methods
extend $object1 => BAZ_QUUX;
check_methods($object1, 1);
my $object1_eigenclass = ref($object1);
ok $object1 == $object1_refaddr;

# make sure there's no change (and no error) when adding
# the same methods
extend $object1 => BAZ_QUUX;
check_methods($object1, 1);
is ref($object1), $object1_eigenclass;
ok $object1 == $object1_refaddr;

# confirm that the eigenclass is the same if we add a new method
# to an already extended object
extend $object1 => { %{ BAZ_QUUX() }, extra => sub { 'Extra' } };
check_methods($object1, 1);
is ref($object1), $object1_eigenclass;
ok $object1 == $object1_refaddr;
is $object1->extra, 'Extra';

# confirm that the value returned is the supplied object
my $object2 = bless {};
my $object2_refaddr = int($object2);
check_methods($object2);
my $object3 = extend $object2 => BAZ_QUUX;
check_methods($object3, 1);
ok $object3 == $object2_refaddr;

# make sure extend $object => with { ... } works
my $object4 = bless {};
my $object4_refaddr = int($object4);
check_methods($object4);
extend $object4 => with BAZ_QUUX;
check_methods($object4, 1);
ok $object4 == $object4_refaddr;

# confirm that extend works if methods are supplied as
# key/value pairs rather than a hashref
my $object5 = bless {};
my $object5_refaddr = int($object5);
check_methods($object5);
extend $object5 => %{ BAZ_QUUX() };
check_methods($object5, 1);
ok $object5 == $object5_refaddr;
