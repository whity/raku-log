unit class Logger::NDC;

has @!stack = ();

method new(*@elements) {
    return self.bless(elements => @elements);
}

submethod BUILD(:@elements) {
    @!stack = @elements.clone;
}

method push(Str $value) {
    @!stack.push($value);
    return self;
}

method pop() {
    @!stack.pop if @!stack.elems;
    return self;
}

method get() {
    return 'undef' if !@!stack.elems;
    return @!stack.join(q{ });
}

method clear() {
    @!stack = ();
    return self;
}

method Array() {
    return @!stack.clone;
}
