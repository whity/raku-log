class X::Log::InvalidLevelException is Exception {
    has Str $.level;

    method message(--> Str) {
        return 'invalid level: ' ~ self.level;
    }
}
