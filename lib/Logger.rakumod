use Logger::NDC;
use Logger::MDC;
use Logger::Exceptions;

unit class Logger;

enum Level <ERROR WARN INFO DEBUG TRACE>;

# class stuff
my %Loggers = ();
my $Lock    = Lock.new;

multi method add(Logger:U: Str $name, Logger $log --> Logger) {
    %Loggers{$name} = $log;
    return $log;
}

multi method add(Logger $log) { return $?CLASS.add('main', $log); }

multi method get(Logger:U: Str $name --> Logger) {
    $Lock.protect({
        if (!%Loggers{$name} && $name eq 'main') {
            $?CLASS.add($name, $?CLASS.new);
        }
    });

    return %Loggers{$name};
}

multi method get(Logger:U:) {
    return $?CLASS.get('main');
}

# instance stuff

has Level $.level is rw;
has Str $.pattern is rw;
has IO::Handle $.output;
has Logger::NDC $.ndc;
has Logger::MDC $.mdc;
has &.dt-formatter is rw = sub ($self) { DateTime.now.Str; };

submethod BUILD(*%args) {
    $!level        = %args{'level'}   || INFO;
    $!output       = %args{'output'}  || $*OUT;
    $!pattern      = %args{'pattern'} || '[%d][%c] %m%n';
    &!dt-formatter = %args{'dt-formatter'} if %args{'dt-formatter'}.defined;

    $!ndc = %args{'ndc'} || Logger::NDC.new;
    $!mdc = %args{'mdc'} || Logger::MDC.new;

    return self;
}

multi method FALLBACK(Str $name, |args) {
    return self!log($name.uc, |@(args));
}

multi method FALLBACK(Str $name where /^is\-.+$/, |args) {
    my $lvl = ($name ~~ /^is\-(.+)$/)[0].Str;
    $lvl = self!get-level($lvl);

    return True if $lvl.value <= self.level.value;
    return False;
}

method clone() {
    return self.new(
        level   => self.level,
        pattern => self.pattern,
        output  => self.output,
        ndc     => Logger::NDC.new(|self.ndc.Array),
        mdc     => Logger::MDC.new(|self.mdc.Hash),
    );
}

method !get-level(Str $level is copy) {
    $level = $level.uc;
    my $exists = Level.enums.first({ .key eq $level });
    return $exists if $exists;

    # throw exception "InvalidLogLevel"
    X::Logger::InvalidLevelException.new(level => $level).throw;
}

method !log(Str $level, Str $message) {
    my $lvl = self!get-level($level);
    return self if $lvl.value > self.level.value;

    # build log message
    my $output = self.pattern;

    my $replace_placeholder = sub ($str is copy, $placeholder, $value) {
        $str ~~ s:g/(^|\s*)(\[?)$placeholder(\]?)(\s*|$)/$0$1$value$2$3/;
        return $str;
    };

    # replace %m
    $output = $replace_placeholder($output, '%m', $message);

    # replace %d
    $output = $replace_placeholder($output, '%d', DateTime.now(formatter => &!dt-formatter).Str);

    # replace %c - level
    $output = $replace_placeholder($output, '%c', $level);

    # replace %n - new line
    $output = $replace_placeholder($output, '%n', "\n");

    # replace %x - NDC
    $output = $replace_placeholder($output, '%x', self.ndc.get);

    # replace %p - process id
    $output = $replace_placeholder($output, '%p', $*PID);

    # replace %X - MDC
    while ((my $match = $output ~~ /(^|\s*)(\[?)\%X\{$<key>=\w+\}(\]?)(\s*|$)/)) {
        my $key = ~($match{'key'});
        my $value = self.mdc.get($key);
        $output = $replace_placeholder($output, sprintf('%%X{%s}', $key), $value);
    }

    # print output
    self.output.print($output);

    return self;
}
