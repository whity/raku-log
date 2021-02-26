class X::Logger::InvalidLevelException is Exception {
    has Str $.level;

    method message(--> Str) {
        return 'invalid level: ' ~ self.level;
    }
}
