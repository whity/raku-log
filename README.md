# Logger

A simple logging class in raku.

## Usage

```raku
use Logger;

sub MAIN() {
    my $log = Logger.new;
    # by default the log level is INFO and the output is $*OUT (can be any IO::Handle)
    # Logger.new(level => Logger::DEBUG, output => $*ERR)

    # log a message
    $log.trace('trace message');
    $log.debug('debug message');
    $log.info('info message');
    $log.warn('warn message');
    $log.error('error message');

    # ndc
    $log.ndc.push('xxx'); # add a value to the stack
    $log.ndc.pop(); # remove the last item from the stack

    # mdc
    $log.mdc.put('key', 'value');

    # change the level
    $log.level = Logger::DEBUG;
    $log.debug('debug message');

    # checking the current log level
    say $log.is-error;
    say $log.is-info;

    # log pattern placeholders
    #   %m -> message
    #   %d -> current datetime
    #   %c -> message level
    #   %n -> new line feed '\n'
    #   %p -> process id
    #   %x -> NDC
    #   %X{key-name} -> MDC

    $log.pattern = '%X{key} %x %m%n';
    $log.info('test');

    # register log object to use in other places
    Logger.add('log-name', Logger.new);
    #Log.add(Logger.new) # register the log object as 'main'

    # get a registered log object
    my $rlog = Logger.get('log-name');
    #my $rlog = Logger.get; returns the log object 'main'

    $rlog.info('from "log-name"');

    # Set a formatter for the datetime
    my $log = Logger.new(formatter => -> $dt { sprintf "%sT%s", .dd-mm-yyyy, .hh-mm-ss given $dt)});
    $log.info('test'); # prints: [20-11-2021T18:31:44][INFO] test
}
```
## Contributing

1. Fork it ( https://github.com/[your-github-name]/raku-log/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- whity(https://github.com/whity) André Brás - creator, maintainer
