pub const word_separators = [_][]const u8{
    " ", ".", ",", ";", ":", "!", "?",
    "\xd8\x9f",
    "\xd8\x8c",
    "'",
    "\xe2\x80\x99",
    "\xe2\x80\x94",
};

pub const sentence_separators = [_][]const u8{
    ".", "!", "?",
    "\xd8\x9f",
};
