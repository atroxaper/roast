use v6;

use Test;

plan 27;

=begin pod

Basic C<kv> tests, see S32::Containers.

=end pod

# L<S32::Containers/"Hash"/=item kv>
{ # check the invocant form
    my %hash = (a => "x", b => "xx", c => "xxx", d => "xxxx");
    my @kv = %hash.kv;
    is(+@kv, 8, '%hash.kv returns the correct number of elems');
    is(~@kv.sort, "a b c d x xx xxx xxxx",  '%hash.kv has no inner list');
}

{ # check the non-invocant form
    my %hash = (a => "x", b => "xx", c => "xxx", d => "xxxx");
    my @kv = kv(%hash);
    is(+@kv, 8, 'kv(%hash) returns the correct number of elems');
    is(~@kv.sort, "a b c d x xx xxx xxxx",  'kv(%hash) has no inner list');
}

# See "Questions about $pair.kv" thread on perl-6 lang
{
    my $pair  = (a => 1);
    my @kv = $pair.kv;
    is(+@kv, 2, '$pair.kv returned one elem');
    is(+@kv, 2, '$pair.kv inner list has two elems');
    is(~@kv, "a 1", '$pair.kv inner list matched expectation');
}

{
    my $sub  = sub (Hash $hash) { $hash.kv };
    my %hash = (a => "x", b => "y");
    is ~kv(%hash).sort,   "a b x y", ".kv works with normal hashes (sanity check)";
    is ~$sub(%hash).sort, "a b x y", ".kv works with constant hash references";
}

{
    # "%$hash" is not idiomatic Perl, but should work nevertheless.
    my $sub  = sub (Hash $hash) { %$hash.kv };
    my %hash = (a => "x", b => "y");
    is ~kv(%hash).sort,   "a b x y", ".kv works with normal hashes (sanity check)";
    is ~$sub(%hash).sort, "a b x y", ".kv works with dereferenced constant hash references";
}

# test3 and test4 illustrate a bug

#?DOES 2
sub test1() is test-assertion {
    my $pair = boo=>'baz';
    my $type = $pair.WHAT.gist;
    for $pair.kv -> $key, $value {
        is($key, 'boo', "test1: $type \$pair got the right \$key");
        is($value, 'baz', "test1: $type \$pair got the right \$value");
    }
}
test1;

#?DOES 2
sub test2() is test-assertion {
    my %pair = boo=>'baz';
    my $type = %pair.WHAT.gist;
    my $elems= +%pair;
    for %pair.kv -> $key, $value {
        is($key, 'boo', "test2: $elems elem $type \%pair got the right \$key");
        is($value, 'baz', "test2: $elems elem $type \%pair got the right \$value");
    }
}
test2;

my %hash  = ('foo' => 'baz');
#?DOES 2
sub test3(%h) is test-assertion {
  for %h.kv -> $key, $value {
        is($key, 'foo', "test3:  from {+%h}-elem {%h.WHAT.gist} \%h got the right \$key");
        is($value, 'baz', "test3: from {+%h}-elem {%h.WHAT.gist} \%h got the right \$value");
  }
}
test3 %hash;

sub test4(%h) is test-assertion {
    for 0..%h.kv.end -> $idx {
        is(%h.kv[$idx], %hash.kv[$idx], "test4: elem $idx of {%h.kv.elems}-elem {%h.kv.WHAT.gist} \%hash.kv correctly accessed");
    }
}
#?DOES 2
test4 %hash;

# sanity
for %hash.kv -> $key, $value {
    is($key, 'foo', "for(): from {+%hash}-elem {%hash.WHAT.gist} \%hash got the right \$key");
    is($value, 'baz', "for(): from {+%hash}-elem {%hash.WHAT.gist} \%hash got the right \$value");
}

# The things returned by .kv should be aliases
{
    my %hash = (:a(1), :b(2), :c(3));

    lives-ok { for %hash.kv -> $key, $value is rw {
        $value += 100;
    } }, 'aliases returned by %hash.kv should be rw (1)';

    is %hash<b>, 102, 'aliases returned by %hash.kv should be rw (2)';
}

{
    my @array = (17, 23, 42);

    lives-ok { for @array.kv -> $key, $value is rw {
        $value += 100;
    } }, 'aliases returned by @array.kv should be rw (1)';

    is @array[1], 123, 'aliases returned by @array.kv should be rw (2)';
}

{
    my $pair = (a => my $ = 42);

    lives-ok { for $pair.kv -> $key, $value is rw {
        $value += 100;
    } }, 'aliases to items returned by $pair.kv should be rw (1)';

    is $pair.value, 142, 'aliases returned by $pair.kv should be rw (2)';
}


# vim: expandtab shiftwidth=4
