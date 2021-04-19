#!/usr/bin/env raku

use Test;
use Logger;

my $log = Logger.new(
    pattern => '%m'
);

is($log.pattern, '%m', 'initial log pattern');

$log.pattern = '[%d] %m';

is($log.pattern, '[%d] %m', 'log pattern changed');

done-testing;
