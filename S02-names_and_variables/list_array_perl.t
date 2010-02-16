use v6;
use Test;
plan 21;

# L<S02/Names and Variables/so that Perl can evaluate the result
# back to the same object>


my @tests = (

    # References to aggregates
    [],
    [ 42 ],  # only one elem
    [< a b c>],
    [ 3..42 ],

    # Infinite arrays, commented because they take infram and inftime in
    # current Pugs
    #?pugs emit #
    #[ 3..Inf ],

    #?pugs emit #
    #[ -Inf..Inf ],

    #?pugs emit #
    #[ 3..42, 17..Inf, -Inf..5 ],

    # Nested arrays
    [      [1,2,3] ],  # only one elem
    [[2,3],4,[6,8]], # three elems
);

# L<S02/Names and Variables/such that standard Perl could reparse the result>
{
    for @tests -> $obj {
        my $s = (~$obj).subst(/\n/, '␤');
        ok eval($obj.perl) eq $obj,
            "($s.perl()).perl returned something whose eval()ed stringification is unchanged";
        is ~(eval($obj.perl).WHAT), ~$obj.WHAT,
            "($s.perl()).perl returned something whose eval()ed .WHAT is unchanged";
    }
}

# Recursive data structures
#?rakudo skip 'recursive data structure'
{
    my $foo = [ 42 ]; $foo[1] = $foo;
    is $foo[1][1][1][0], 42, "basic recursive arrayref";

    #?pugs skip 'hanging test'
    is ~$foo.perl.eval, ~$foo,
        ".perl worked correctly on a recursive arrayref";
}

{
    # test bug in .perl on result of hyperoperator
    # first the trivial case without hyperop
    my @foo = ([-1, -2], -3);
    is @foo.perl, '[[-1, -2], -3]', ".perl on a nested list";

    #?rakudo emit # parsefail on hyper operator
    my @hyp = -« ([1, 2], 3);
    # what it currently (r16460) gives
    #?rakudo 2 skip 'parsefail on hyper operator'
    #?pugs 2 todo 'bug'
    isnt @hyp.perl, '[(-1, -2), -3]', "strange inner parens from .perl on result of hyperop";

    # what it should give
    is @hyp.perl, '[[-1, -2], -3]', ".perl on a nested list result of hyper operator";
}

{
    # beware: S02 says that .perl should evaluate the invocant in item
    # context, so eval @thing.perl returns a scalar. Always.

    # L<S02/Names and Variables/regenerate the object as a scalar in
    # item context>


    my @list = (1, 2);
    push @list, eval (3, 4).perl;
    #?rakudo skip "List.perl bug"
    is +@list, 3, 'eval(@list.perl) gives a list, not an array ref';
}

# RT #63724
{
    my @original      = (1,2,3);
    my $dehydrated    = @original.perl;
    my @reconstituted = @( eval $dehydrated );

    is @reconstituted, @original,
       "eval of .perl returns original for '$dehydrated'";

    @original      = (1,);
    $dehydrated    = @original.perl;
    @reconstituted = @( eval $dehydrated );

    is @reconstituted, @original,
       "eval of .perl returns original for '$dehydrated'";
}

# RT #65988
{
    my $rt65988 = (\(1,2), \(3,4));
    #?rakudo skip 'RT 65988'
    is_deeply eval( $rt65988.perl ), $rt65988, $rt65988.perl ~ '.perl';
}

done_testing;

# vim: ft=perl6

