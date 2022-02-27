#!/usr/bin/env raku

use Test;
use Logger;

class Handle is IO::Handle {
    has Str $!message;

    method get() { return $!message; }
    method print($value) {
        $!message = $value;
        return self;
    }
}

{
    my $log = Logger.new(output => Handle.new);

    my $msg = 'test message';
    $log.info($msg);
    like($log.output.get, /^ '[' \d+ '-' \d+ '-' \d+ 'T' \d+ ':' \d+ ':' \d+ '.' \d+ 'Z]'?/, 'standard timestamp');
}

{
    my &formatter = -> $dt { sprintf "%sT%s", .dd-mm-yyyy, .hh-mm-ss given $dt };
    my $log = Logger.new(output => Handle.new, dt-formatter => &formatter);

    my $msg = 'test message';
    $log.info($msg);
    like($log.output.get, /^ '[' \d+ '-' \d+ '-' \d+ 'T' \d+ ':' \d+ ':' \d+ ']'/, 'changed timestamp');
}

done-testing;
