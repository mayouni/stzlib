// Softanza Engine -- String Operations (Tier 1)
//
// Domain functions for string manipulation. Shared infrastructure
// (types, lifecycle, helpers) lives in string/core.zig.
//
// Phase D module separation: core.zig holds StzString, lifecycle,
// error reporting, indexing config, and shared helpers. This file
// holds all domain functions and re-exports core's public API.

const std = @import("std");

// ─── Core imports ───
const core = @import("string/core.zig");

// Re-export core public API (callers see a flat namespace)
pub const StrError = core.StrError;
pub const StzStringHandle = core.StzStringHandle;
pub const StzFindResultHandle = core.StzFindResultHandle;
pub const INDEX_BASE = core.INDEX_BASE;
pub const str_last_error = core.str_last_error;
pub const str_clear_error = core.str_clear_error;
pub const str_new = core.str_new;
pub const str_from = core.str_from;
pub const str_free = core.str_free;
pub const str_data = core.str_data;
pub const str_size = core.str_size;
pub const str_count = core.str_count;
pub const str_append = core.str_append;
pub const str_insert = core.str_insert;

// Local aliases for core types and helpers
const mem = core.mem;
const gpa = core.gpa;
const unicode = core.unicode;
const StzString = core.StzString;
const StzFindResult = core.StzFindResult;
const setError = core.setError;
const toInternal = core.toInternal;
const toExternal = core.toExternal;
const casefoldAlloc = core.casefoldAlloc;
const ciEqlUnicode = core.ciEqlUnicode;
const ciMatch = core.ciMatch;
const toLowerAscii = core.toLowerAscii;
const utf8CodepointCount = core.utf8CodepointCount;
const codepointIndexToByteOffset = core.codepointIndexToByteOffset;
const byteOffsetToCodepointIndex = core.byteOffsetToCodepointIndex;
const decodeCodepoint = core.decodeCodepoint;
const isAllAscii = core.isAllAscii;
const bmhSearch = core.bmhSearch;
const formatUsize = core.formatUsize;
const isVowelAscii = core.isVowelAscii;

// ─── Encode submodule imports ───
const encode = @import("string/encode.zig");

// Re-export encode public API
pub const str_url_encode = encode.str_url_encode;
pub const str_url_decode = encode.str_url_decode;
pub const str_encode_hex = encode.str_encode_hex;
pub const str_decode_hex = encode.str_decode_hex;
pub const str_to_hex = encode.str_to_hex;
pub const str_from_hex = encode.str_from_hex;
pub const str_escape_html = encode.str_escape_html;
pub const str_unescape_html = encode.str_unescape_html;
pub const str_to_base64 = encode.str_to_base64;
pub const str_from_base64 = encode.str_from_base64;
pub const str_to_binary = encode.str_to_binary;
pub const str_from_binary = encode.str_from_binary;
pub const str_to_morse = encode.str_to_morse;
pub const str_quote = encode.str_quote;
pub const str_unquote = encode.str_unquote;
pub const str_to_csv_field = encode.str_to_csv_field;
pub const str_caesar = encode.str_caesar;
pub const str_xor_cipher = encode.str_xor_cipher;
pub const str_vigenere_encrypt = encode.str_vigenere_encrypt;
pub const str_atbash = encode.str_atbash;
pub const str_rot47 = encode.str_rot47;
pub const str_zigzag = encode.str_zigzag;
pub const str_hash = encode.str_hash;
pub const str_entropy = encode.str_entropy;

// ─── NLP submodule imports ───
const nlp = @import("string/nlp.zig");

pub const str_levenshtein = nlp.str_levenshtein;
pub const str_hamming_distance = nlp.str_hamming_distance;
pub const str_jaro = nlp.str_jaro;
pub const str_jaro_winkler = nlp.str_jaro_winkler;
pub const str_jaccard_similarity = nlp.str_jaccard_similarity;
pub const str_soundex = nlp.str_soundex;
pub const str_metaphone = nlp.str_metaphone;
pub const str_ngram = nlp.str_ngram;
pub const str_ngram_count = nlp.str_ngram_count;
pub const str_char_ngrams = nlp.str_char_ngrams;
pub const str_word_ngrams = nlp.str_word_ngrams;
pub const str_extract_numbers = nlp.str_extract_numbers;
pub const str_extract_emails = nlp.str_extract_emails;
pub const str_extract_words = nlp.str_extract_words;
pub const str_pluralize = nlp.str_pluralize;
pub const str_to_pig_latin = nlp.str_to_pig_latin;
pub const str_to_nato = nlp.str_to_nato;
pub const str_mask_email = nlp.str_mask_email;

// ─── Split submodule imports ───
const split = @import("string/split.zig");

pub const str_split_count = split.str_split_count;
pub const str_split_get = split.str_split_get;
pub const str_split_count_cs = split.str_split_count_cs;
pub const str_split_count_ci = split.str_split_count_ci;
pub const str_split_get_cs = split.str_split_get_cs;
pub const str_split_get_ci = split.str_split_get_ci;
pub const str_lines_count = split.str_lines_count;
pub const str_lines_split_count = split.str_lines_split_count;
pub const str_line_at = split.str_line_at;
pub const str_count_lines = split.str_count_lines;
pub const str_word_count = split.str_word_count;
pub const str_count_words = split.str_count_words;
pub const str_word_at = split.str_word_at;
pub const str_nth_word = split.str_nth_word;
pub const str_first_word = split.str_first_word;
pub const str_last_word = split.str_last_word;
pub const str_swap_words = split.str_swap_words;
pub const str_sentence_count = split.str_sentence_count;
pub const str_partition = split.str_partition;
pub const str_partition_after = split.str_partition_after;
pub const str_rpartition = split.str_rpartition;
pub const str_rpartition_after = split.str_rpartition_after;
pub const str_chunk = split.str_chunk;
pub const str_chars_split = split.str_chars_split;

// ─── Find submodule imports ───
const find = @import("string/find.zig");

pub const str_index_of_cs = find.str_index_of_cs;
pub const str_index_of = find.str_index_of;
pub const str_index_of_from_cs = find.str_index_of_from_cs;
pub const str_index_of_from = find.str_index_of_from;
pub const str_index_of_ci = find.str_index_of_ci;
pub const str_byte_to_cp = find.str_byte_to_cp;
pub const str_count_of = find.str_count_of;
pub const str_count_of_cs = find.str_count_of_cs;
pub const str_count_of_ci = find.str_count_of_ci;
pub const str_find_all_cs = find.str_find_all_cs;
pub const str_find_all = find.str_find_all;
pub const str_find_all_ci = find.str_find_all_ci;
pub const stz_find_result_count = find.stz_find_result_count;
pub const stz_find_result_get = find.stz_find_result_get;
pub const stz_find_result_free = find.stz_find_result_free;
pub const str_last_index_of_cs = find.str_last_index_of_cs;
pub const str_last_index_of = find.str_last_index_of;
pub const str_last_index_of_ci = find.str_last_index_of_ci;
pub const str_contains_cs = find.str_contains_cs;
pub const str_contains = find.str_contains;
pub const str_contains_ci = find.str_contains_ci;
pub const str_starts_with_cs = find.str_starts_with_cs;
pub const str_starts_with = find.str_starts_with;
pub const str_starts_with_ci = find.str_starts_with_ci;
pub const str_ends_with_cs = find.str_ends_with_cs;
pub const str_ends_with = find.str_ends_with;
pub const str_ends_with_ci = find.str_ends_with_ci;
pub const str_equals_cs = find.str_equals_cs;
pub const str_equals = find.str_equals;
pub const str_equals_ci = find.str_equals_ci;
pub const str_find_nth_cs = find.str_find_nth_cs;
pub const str_find_nth = find.str_find_nth;
pub const str_find_nth_ci = find.str_find_nth_ci;
pub const str_starts_with_digit = find.str_starts_with_digit;
pub const str_starts_with_letter = find.str_starts_with_letter;
pub const str_ends_with_digit = find.str_ends_with_digit;
pub const str_ends_with_letter = find.str_ends_with_letter;
pub const str_find_all_char = find.str_find_all_char;
pub const str_starts_with_any = find.str_starts_with_any;
pub const str_ends_with_any = find.str_ends_with_any;

// ─── Replace submodule imports ───
const replace = @import("string/replace.zig");

pub const str_replace_range = replace.str_replace_range;
pub const str_replace_cs = replace.str_replace_cs;
pub const str_replace = replace.str_replace;
pub const str_replace_ci = replace.str_replace_ci;
pub const str_replace_first = replace.str_replace_first;
pub const str_replace_last = replace.str_replace_last;
pub const str_replace_nth = replace.str_replace_nth;
pub const str_replace_char_at = replace.str_replace_char_at;
pub const str_replace_substring = replace.str_replace_substring;
pub const str_replace_char = replace.str_replace_char;
pub const str_replace_at = replace.str_replace_at;
pub const str_replace2 = replace.str_replace2;
pub const str_replace_any_char = replace.str_replace_any_char;
pub const str_replace_between = replace.str_replace_between;
pub const str_remove_range = replace.str_remove_range;
pub const str_remove_all_cs = replace.str_remove_all_cs;
pub const str_remove_all = replace.str_remove_all;
pub const str_remove_all_ci = replace.str_remove_all_ci;
pub const str_remove_char_at = replace.str_remove_char_at;
pub const str_remove_chars_of_type = replace.str_remove_chars_of_type;
pub const str_remove_consecutive_duplicates = replace.str_remove_consecutive_duplicates;
pub const str_remove_first_occurrence = replace.str_remove_first_occurrence;
pub const str_remove_last_occurrence = replace.str_remove_last_occurrence;
pub const str_remove_nth_occurrence = replace.str_remove_nth_occurrence;
pub const str_remove_prefix = replace.str_remove_prefix;
pub const str_remove_suffix = replace.str_remove_suffix;
pub const str_remove_whitespace = replace.str_remove_whitespace;
pub const str_remove_between = replace.str_remove_between;
pub const str_remove_vowels = replace.str_remove_vowels;
pub const str_remove_duplicate_words = replace.str_remove_duplicate_words;
pub const str_remove_punctuation = replace.str_remove_punctuation;
pub const str_remove_nth_word = replace.str_remove_nth_word;
pub const str_remove_blank_lines = replace.str_remove_blank_lines;
pub const str_insert_cp = replace.str_insert_cp;
pub const str_insert_before_each = replace.str_insert_before_each;
pub const str_insert_after_each = replace.str_insert_after_each;
pub const str_insert_word_at = replace.str_insert_word_at;
pub const str_strip_chars = replace.str_strip_chars;
pub const str_keep_chars = replace.str_keep_chars;

// ─── Transform submodule imports ───
const transform = @import("string/transform.zig");

pub const str_to_upper = transform.str_to_upper;
pub const str_to_lower = transform.str_to_lower;
pub const str_foldcase = transform.str_foldcase;
pub const str_to_title = transform.str_to_title;
pub const str_swap_case = transform.str_swap_case;
pub const str_capitalize_first = transform.str_capitalize_first;
pub const str_decapitalize_first = transform.str_decapitalize_first;
pub const str_to_camel_case = transform.str_to_camel_case;
pub const str_to_snake_case = transform.str_to_snake_case;
pub const str_to_kebab_case = transform.str_to_kebab_case;
pub const str_to_pascal_case = transform.str_to_pascal_case;
pub const str_capitalize_words = transform.str_capitalize_words;
pub const str_to_sentence_case = transform.str_to_sentence_case;
pub const str_to_alternating_case = transform.str_to_alternating_case;
pub const str_to_title_case_strict = transform.str_to_title_case_strict;
pub const str_to_spongebob_case = transform.str_to_spongebob_case;
pub const str_to_dot_case = transform.str_to_dot_case;
pub const str_to_path_case = transform.str_to_path_case;
pub const str_to_constant_case = transform.str_to_constant_case;

// ─── Inspect submodule imports ───
const inspect = @import("string/inspect.zig");

pub const str_is_empty = inspect.str_is_empty;
pub const str_is_numeric = inspect.str_is_numeric;
pub const str_is_alpha = inspect.str_is_alpha;
pub const str_is_palindrome = inspect.str_is_palindrome;
pub const str_is_ascii = inspect.str_is_ascii;
pub const str_is_uppercase = inspect.str_is_uppercase;
pub const str_is_lowercase = inspect.str_is_lowercase;
pub const str_is_whitespace = inspect.str_is_whitespace;
pub const str_is_only_type = inspect.str_is_only_type;
pub const str_is_title_case = inspect.str_is_title_case;
pub const str_is_alpha_only = inspect.str_is_alpha_only;
pub const str_is_alnum = inspect.str_is_alnum;
pub const str_contains_char = inspect.str_contains_char;
pub const str_is_word = inspect.str_is_word;
pub const str_is_numeric_string = inspect.str_is_numeric_string;
pub const str_is_hex_string = inspect.str_is_hex_string;
pub const str_is_binary_string = inspect.str_is_binary_string;
pub const str_is_octal_string = inspect.str_is_octal_string;
pub const str_is_chars_sorted_asc = inspect.str_is_chars_sorted_asc;
pub const str_is_chars_sorted_desc = inspect.str_is_chars_sorted_desc;
pub const str_contains_any_of = inspect.str_contains_any_of;
pub const str_contains_all_of = inspect.str_contains_all_of;
pub const str_is_alphanumeric = inspect.str_is_alphanumeric;
pub const str_is_digit = inspect.str_is_digit;
pub const str_is_blank = inspect.str_is_blank;
pub const str_is_identifier = inspect.str_is_identifier;
pub const str_contains_only = inspect.str_contains_only;
pub const str_is_anagram = inspect.str_is_anagram;
pub const str_is_pangram = inspect.str_is_pangram;
pub const str_is_balanced = inspect.str_is_balanced;
pub const str_is_email_like = inspect.str_is_email_like;
pub const str_is_url_like = inspect.str_is_url_like;
pub const str_is_float = inspect.str_is_float;
pub const str_is_camel_case = inspect.str_is_camel_case;
pub const str_is_snake_case = inspect.str_is_snake_case;
pub const str_is_kebab_case = inspect.str_is_kebab_case;
pub const str_is_palindrome_words = inspect.str_is_palindrome_words;
pub const str_is_isogram = inspect.str_is_isogram;

// ─── Extract submodule imports ───
const extract = @import("string/extract.zig");

pub const str_mid = extract.str_mid;
pub const str_left = extract.str_left;
pub const str_right = extract.str_right;
pub const str_trimmed = extract.str_trimmed;
pub const str_nth_char = extract.str_nth_char;
pub const str_slice = extract.str_slice;
pub const str_chars = extract.str_chars;
pub const str_chars_free = extract.str_chars_free;
pub const str_char_at = extract.str_char_at;
pub const str_mid_cp = extract.str_mid_cp;
pub const str_left_cp = extract.str_left_cp;
pub const str_right_cp = extract.str_right_cp;
pub const str_grapheme_count = extract.str_grapheme_count;
pub const str_normalize = extract.str_normalize;
pub const str_strip_marks = extract.str_strip_marks;
pub const str_between = extract.str_between;
pub const str_between_nth = extract.str_between_nth;
pub const str_count_between = extract.str_count_between;
pub const str_substring = extract.str_substring;
pub const str_chars_between = extract.str_chars_between;
pub const str_char_at_to_string = extract.str_char_at_to_string;
pub const str_between_first = extract.str_between_first;
pub const str_cp_count = extract.str_cp_count;

// ─── Trim submodule imports ───
const trim = @import("string/trim.zig");

pub const str_trim = trim.str_trim;
pub const str_trim_left = trim.str_trim_left;
pub const str_trim_right = trim.str_trim_right;
pub const str_simplify = trim.str_simplify;
pub const str_trim_chars = trim.str_trim_chars;
pub const str_pad_left = trim.str_pad_left;
pub const str_pad_right = trim.str_pad_right;
pub const str_center = trim.str_center;
pub const str_center_pad = trim.str_center_pad;
pub const str_zfill = trim.str_zfill;
pub const str_ljust = trim.str_ljust;
pub const str_rjust = trim.str_rjust;
pub const str_left_pad = trim.str_left_pad;
pub const str_right_pad = trim.str_right_pad;
pub const str_indent = trim.str_indent;
pub const str_dedent = trim.str_dedent;
pub const str_tab_expand = trim.str_tab_expand;
pub const str_expand_tabs = trim.str_expand_tabs;
pub const str_collapse_spaces = trim.str_collapse_spaces;
pub const str_normalize_spaces = trim.str_normalize_spaces;
pub const str_squeeze = trim.str_squeeze;
pub const str_squeeze_char = trim.str_squeeze_char;

// ─── Search ───

/// Unified index_of with case sensitivity parameter.
/// case=1: case-sensitive, case=0: case-insensitive (Unicode casefold).
// str_index_of_cs, str_index_of, str_index_of_from_cs, str_index_of_from, str_index_of_ci -> string/find.zig
// str_byte_to_cp, str_count_of -> string/find.zig

// str_replace_range -> string/replace.zig

// str_split_count, str_split_get -> string/split.zig

// Find all, find result accessors, last_index_of, count_of_cs/ci -> string/find.zig
// contains, starts_with, ends_with (all CS variants) -> string/find.zig

// ─── Transform ───


// str_replace_cs -> string/replace.zig

// str_replace -> string/replace.zig

// str_replace_ci -> string/replace.zig

// Split CS (split_count_cs, split_count_ci, split_get_cs, split_get_ci) -> string/split.zig

// str_to_upper -> string/transform.zig

// str_to_lower -> string/transform.zig

// str_foldcase -> string/transform.zig

// str_char_at -> string/extract.zig
// str_mid_cp -> string/extract.zig
// str_left_cp -> string/extract.zig
// str_right_cp -> string/extract.zig

// str_insert_cp -> string/replace.zig

// str_grapheme_count -> string/extract.zig
// str_normalize -> string/extract.zig
// str_strip_marks -> string/extract.zig

// str_to_title -> string/transform.zig

/// Reverse the codepoints in the string. Returns a new handle.
pub fn str_reverse(handle: StzStringHandle) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        if (src.len == 0) return str_new();

        // Count codepoints to allocate offset array
        const cp_count = utf8CodepointCount(src);
        const offsets = gpa.alloc(usize, cp_count + 1) catch return str_new();
        defer gpa.free(offsets);

        // Fill offset array with byte positions of each codepoint
        var i: usize = 0;
        var idx: usize = 0;
        while (i < src.len) {
            offsets[idx] = i;
            idx += 1;
            const cp_len = std.unicode.utf8ByteSequenceLength(src[i]) catch 1;
            i += cp_len;
        }
        offsets[idx] = src.len;

        const r = str_new() orelse return null;
        r.data.ensureTotalCapacity(gpa, src.len) catch { setError(.out_of_memory); };

        // Walk codepoints in reverse order
        var k: usize = cp_count;
        while (k > 0) {
            k -= 1;
            const start = offsets[k];
            const end = offsets[k + 1];
            r.data.appendSlice(gpa, src[start..end]) catch { setError(.out_of_memory); };
        }
        return r;
    }
    return str_new();
}

/// Repeat the string `count` times. Returns a new handle.
pub fn str_repeat(handle: StzStringHandle, count: c_int) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const src = s.slice();
        if (src.len == 0 or count <= 0) return str_new();
        const n: usize = @intCast(count);
        const r = str_new() orelse return null;
        r.data.ensureTotalCapacity(gpa, src.len * n) catch { setError(.out_of_memory); };
        for (0..n) |_| {
            r.data.appendSlice(gpa, src) catch { setError(.out_of_memory); };
        }
        return r;
    }
    return str_new();
}

// str_pad_left -> string/trim.zig
// str_pad_right -> string/trim.zig

// str_remove_range -> string/replace.zig

// str_trim_left -> string/trim.zig
// str_trim_right -> string/trim.zig

/// Check if two strings are equal (case-sensitive). Returns 1 or 0.
/// Unified equals with case sensitivity parameter.
// str_equals_cs, str_equals, str_equals_ci -> string/find.zig
// str_find_nth_cs, str_find_nth, str_find_nth_ci -> string/find.zig

// ─── Replace First / Last / Nth ───

// str_replace_first -> string/replace.zig

// str_replace_last -> string/replace.zig

// str_replace_nth -> string/replace.zig

// ─── String Queries ───

// str_is_empty -> string/inspect.zig

/// Extract the substring between the first occurrence of `open` and the first
/// subsequent occurrence of `close`. Returns new handle, or null if not found.
// str_between -> string/extract.zig

/// Count how many codepoints match a predicate class.
/// Classes: 0=letter, 1=digit, 2=whitespace, 3=uppercase, 4=lowercase, 5=punctuation
pub fn str_count_chars_of_type(handle: StzStringHandle, char_type: c_int) callconv(.c) c_int {
    if (handle) |s| {
        const bytes = s.slice();
        var i: usize = 0;
        var count: c_int = 0;
        while (i < bytes.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            const matches: bool = switch (char_type) {
                0 => unicode.stz_unicode_is_letter(cp_val) == 1,
                1 => unicode.stz_unicode_is_digit(cp_val) == 1,
                2 => unicode.stz_unicode_is_space(cp_val) == 1,
                3 => unicode.stz_unicode_is_upper(cp_val) == 1,
                4 => unicode.stz_unicode_is_lower(cp_val) == 1,
                5 => unicode.stz_unicode_is_letter(cp_val) == 0 and unicode.stz_unicode_is_digit(cp_val) == 0 and unicode.stz_unicode_is_space(cp_val) == 0 and cp_val >= 33 and cp_val <= 126,
                else => false,
            };
            if (matches) count += 1;
            i += cp_len;
        }
        return count;
    }
    return 0;
}

// str_is_numeric -> string/inspect.zig

// str_is_alpha -> string/inspect.zig

// ─── Remove / Lines / Palindrome ───

// str_remove_all_cs -> string/replace.zig

// str_remove_all -> string/replace.zig

// str_lines_count -> string/split.zig

// str_is_palindrome -> string/inspect.zig

/// Find positions (0-based codepoint indices) of characters matching a type.
/// Types: 0=letter, 1=digit, 2=space, 3=upper, 4=lower, 5=punct
pub fn str_find_chars_of_type(handle: StzStringHandle, char_type: c_int) callconv(.c) StzFindResultHandle {
    const r = gpa.create(StzFindResult) catch return null;
    r.* = StzFindResult.init();
    if (handle) |s| {
        const bytes = s.slice();
        var i: usize = 0;
        var cp_idx: usize = 0;
        while (i < bytes.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            const matches: bool = switch (char_type) {
                0 => unicode.stz_unicode_is_letter(cp_val) == 1,
                1 => unicode.stz_unicode_is_digit(cp_val) == 1,
                2 => unicode.stz_unicode_is_space(cp_val) == 1,
                3 => unicode.stz_unicode_is_upper(cp_val) == 1,
                4 => unicode.stz_unicode_is_lower(cp_val) == 1,
                5 => unicode.stz_unicode_is_letter(cp_val) == 0 and unicode.stz_unicode_is_digit(cp_val) == 0 and unicode.stz_unicode_is_space(cp_val) == 0 and cp_val >= 33 and cp_val <= 126,
                else => false,
            };
            if (matches) {
                r.positions.append(gpa, toExternal(cp_idx)) catch break;
            }
            cp_idx += 1;
            i += cp_len;
        }
    }
    return r;
}

/// Extract characters matching a type as a new string (letters only, digits only, etc).
/// Types: 0=letter, 1=digit, 2=space, 3=upper, 4=lower
pub fn str_extract_chars_of_type(handle: StzStringHandle, char_type: c_int) callconv(.c) StzStringHandle {
    if (handle) |s| {
        const bytes = s.slice();
        const result = str_new() orelse return null;
        var i: usize = 0;
        while (i < bytes.len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
            const cp_end = @min(i + cp_len, bytes.len);
            const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
            const matches: bool = switch (char_type) {
                0 => unicode.stz_unicode_is_letter(cp_val) == 1,
                1 => unicode.stz_unicode_is_digit(cp_val) == 1,
                2 => unicode.stz_unicode_is_space(cp_val) == 1,
                3 => unicode.stz_unicode_is_upper(cp_val) == 1,
                4 => unicode.stz_unicode_is_lower(cp_val) == 1,
                5 => unicode.stz_unicode_is_letter(cp_val) == 0 and unicode.stz_unicode_is_digit(cp_val) == 0 and unicode.stz_unicode_is_space(cp_val) == 0 and cp_val >= 33 and cp_val <= 126,
                else => false,
            };
            if (matches) {
                result.data.appendSlice(gpa, bytes[i..cp_end]) catch break;
            }
            i += cp_len;
        }
        return result;
    }
    return null;
}

// str_is_ascii -> string/inspect.zig

// str_remove_char_at -> string/replace.zig

/// Return the character type at a codepoint index (INDEX_BASE convention).
/// Returns: 0=letter, 1=digit, 2=space, 3=upper, 4=lower, 5=punct, -1=invalid
pub fn str_char_type_at(handle: StzStringHandle, cp_index: c_int) callconv(.c) c_int {
    if (handle) |s| {
        const src = s.slice();
        if (cp_index < INDEX_BASE) return -1;
        const idx: usize = toInternal(@intCast(cp_index));
        const byte_offset = codepointIndexToByteOffset(src, idx);
        if (byte_offset >= src.len) return -1;
        const cp_len = std.unicode.utf8ByteSequenceLength(src[byte_offset]) catch return -1;
        const cp_val: i32 = decodeCodepoint(src, byte_offset, cp_len);
        if (cp_val < 0) return -1;
        if (unicode.stz_unicode_is_upper(cp_val) == 1) return 3;
        if (unicode.stz_unicode_is_lower(cp_val) == 1) return 4;
        if (unicode.stz_unicode_is_letter(cp_val) == 1) return 0;
        if (unicode.stz_unicode_is_digit(cp_val) == 1) return 1;
        if (unicode.stz_unicode_is_space(cp_val) == 1) return 2;
        return 5; // punctuation/other
    }
    return -1;
}

/// Concatenate two strings, returning a new handle.
pub fn str_concat(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) StzStringHandle {
    const result = str_new() orelse return null;
    if (h1) |s1| result.data.appendSlice(gpa, s1.slice()) catch return null;
    if (h2) |s2| result.data.appendSlice(gpa, s2.slice()) catch return null;
    return result;
}

// str_is_uppercase -> string/inspect.zig

// str_is_lowercase -> string/inspect.zig

// str_is_whitespace -> string/inspect.zig

// str_word_count -> string/split.zig

// str_is_only_type -> string/inspect.zig

// str_remove_chars_of_type -> string/replace.zig

// str_trim -> string/trim.zig

// str_swap_case -> string/transform.zig

// str_simplify -> string/trim.zig

// str_starts_with_digit, str_starts_with_letter, str_ends_with_digit, str_ends_with_letter -> string/find.zig

// str_replace_char_at -> string/replace.zig

/// Compute Levenshtein edit distance between two strings (codepoint-level).
// Levenshtein -> string/nlp.zig

// str_is_title_case -> string/inspect.zig

// str_lines_split_count, str_line_at -> string/split.zig

/// Return a new string with duplicate codepoints removed (preserves first occurrence order).
pub fn str_unique_chars(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = (handle orelse return null);
    const bytes = s.slice();
    const result = str_new() orelse return null;

    // Track seen codepoints with a simple array (works for BMP + beyond)
    var seen = std.AutoHashMap(i32, void).init(gpa);
    defer seen.deinit();

    var i: usize = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_end = @min(i + cp_len, bytes.len);
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        if (!seen.contains(cp_val)) {
            seen.put(cp_val, {}) catch break;
            result.data.appendSlice(gpa, bytes[i..cp_end]) catch break;
        }
        i += cp_len;
    }
    return result;
}

// str_remove_all_ci -> string/replace.zig

// str_is_alpha_only -> string/inspect.zig

// str_is_alnum -> string/inspect.zig

/// Return number of unique codepoints.
pub fn str_unique_char_count(handle: StzStringHandle) callconv(.c) c_int {
    const s = (handle orelse return 0);
    const bytes = s.slice();
    var seen = std.AutoHashMap(i32, void).init(gpa);
    defer seen.deinit();
    var i: usize = 0;
    while (i < bytes.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(bytes[i]) catch 1;
        const cp_val: i32 = decodeCodepoint(bytes, i, cp_len);
        seen.put(cp_val, {}) catch break;
        i += cp_len;
    }
    return @intCast(seen.count());
}

// str_contains_char -> string/inspect.zig

// str_between_nth -> string/extract.zig
// str_count_between -> string/extract.zig

// ─── Tests ───

test "string lifecycle" {
    const s = str_new();
    try std.testing.expect(s != null);
    try std.testing.expectEqual(@as(usize, 0), str_size(s));

    str_append(s, "Hello", 5);
    try std.testing.expectEqual(@as(usize, 5), str_size(s));

    str_append(s, " World", 6);
    try std.testing.expectEqual(@as(usize, 11), str_size(s));

    str_free(s);
}

test "string from" {
    const s = str_from("Softanza", 8);
    try std.testing.expect(s != null);
    try std.testing.expectEqual(@as(usize, 8), str_size(s));
    try std.testing.expectEqual(@as(usize, 8), str_count(s));

    const data = str_data(s);
    try std.testing.expect(mem.eql(u8, data[0..8], "Softanza"));

    str_free(s);
}

test "string unicode count" {
    const s = str_from("caf\xC3\xA9", 5);
    try std.testing.expectEqual(@as(usize, 5), str_size(s));
    try std.testing.expectEqual(@as(usize, 4), str_count(s));
    str_free(s);
}

test "string search" {
    const s = str_from("Hello Ring World", 16);

    try std.testing.expectEqual(@as(i64, 7), str_index_of(s, "Ring", 4));
    try std.testing.expectEqual(@as(i64, -1), str_index_of(s, "Zig", 3));
    try std.testing.expectEqual(@as(c_int, 1), str_contains(s, "World", 5));
    try std.testing.expectEqual(@as(c_int, 1), str_starts_with(s, "Hello", 5));
    try std.testing.expectEqual(@as(c_int, 1), str_ends_with(s, "World", 5));
    try std.testing.expectEqual(@as(c_int, 0), str_starts_with(s, "Ring", 4));

    str_free(s);
}

test "string mid/left/right" {
    const s = str_from("Softanza", 8);

    const mid = str_mid(s, 4, 4);
    try std.testing.expect(mem.eql(u8, str_data(mid)[0..4], "anza"));
    str_free(mid);

    const left = str_left(s, 4);
    try std.testing.expect(mem.eql(u8, str_data(left)[0..4], "Soft"));
    str_free(left);

    const right = str_right(s, 4);
    try std.testing.expect(mem.eql(u8, str_data(right)[0..4], "anza"));
    str_free(right);

    str_free(s);
}

test "string replace" {
    const s = str_from("Hello Qt World", 14);
    str_replace(s, "Qt", 2, "Zig", 3);
    try std.testing.expectEqual(@as(usize, 15), str_size(s));
    try std.testing.expect(mem.eql(u8, str_data(s)[0..15], "Hello Zig World"));
    str_free(s);
}

test "string trimmed" {
    const s = str_from("  hello  ", 9);
    const trimmed = str_trimmed(s);
    try std.testing.expectEqual(@as(usize, 5), str_size(trimmed));
    try std.testing.expect(mem.eql(u8, str_data(trimmed)[0..5], "hello"));
    str_free(trimmed);
    str_free(s);
}

test "string case" {
    const s = str_from("Hello", 5);

    const upper = str_to_upper(s);
    try std.testing.expect(mem.eql(u8, str_data(upper)[0..5], "HELLO"));
    str_free(upper);

    const lower = str_to_lower(s);
    try std.testing.expect(mem.eql(u8, str_data(lower)[0..5], "hello"));
    str_free(lower);

    str_free(s);
}

test "string unicode case" {
    // Greek lowercase -> uppercase
    const s = str_from("\xCE\xB1\xCE\xB2\xCE\xB3", 6);
    const upper = str_to_upper(s);
    try std.testing.expectEqual(@as(usize, 6), str_size(upper));
    try std.testing.expect(mem.eql(u8, str_data(upper)[0..6], "\xCE\x91\xCE\x92\xCE\x93"));
    str_free(upper);
    str_free(s);
}

test "string char_at codepoint" {
    // "cafe\xCC\x81" = c(0x63) a(0x61) f(0x66) e-acute(0xE9 as 2 bytes)
    const s = str_from("caf\xC3\xA9", 5);
    try std.testing.expectEqual(@as(i32, 'c'), str_char_at(s, 1));
    try std.testing.expectEqual(@as(i32, 'a'), str_char_at(s, 2));
    try std.testing.expectEqual(@as(i32, 'f'), str_char_at(s, 3));
    try std.testing.expectEqual(@as(i32, 0xE9), str_char_at(s, 4));
    try std.testing.expectEqual(@as(i32, -1), str_char_at(s, 5));
    str_free(s);
}

test "string mid_cp" {
    // "cafe\xCC\x81" (4 codepoints, 5 bytes)
    const s = str_from("caf\xC3\xA9", 5);
    const mid = str_mid_cp(s, 3, 2);
    try std.testing.expectEqual(@as(usize, 3), str_size(mid));
    try std.testing.expect(mem.eql(u8, str_data(mid)[0..3], "f\xC3\xA9"));
    str_free(mid);
    str_free(s);
}

test "string grapheme count" {
    // e + combining acute = 1 grapheme
    const s = str_from("e\xCC\x81", 3);
    try std.testing.expectEqual(@as(usize, 2), str_count(s)); // 2 codepoints
    try std.testing.expectEqual(@as(c_int, 1), str_grapheme_count(s)); // 1 grapheme
    str_free(s);
}

test "string normalize" {
    // NFD: e + combining acute -> NFC: e-acute
    const s = str_from("e\xCC\x81", 3);
    const nfc = str_normalize(s, 0);
    try std.testing.expectEqual(@as(usize, 2), str_size(nfc));
    try std.testing.expect(mem.eql(u8, str_data(nfc)[0..2], "\xC3\xA9"));
    str_free(nfc);
    str_free(s);
}

test "string strip marks" {
    const s = str_from("\xC3\xA9", 2); // e-acute
    const stripped = str_strip_marks(s);
    try std.testing.expectEqual(@as(usize, 1), str_size(stripped));
    try std.testing.expect(mem.eql(u8, str_data(stripped)[0..1], "e"));
    str_free(stripped);
    str_free(s);
}

test "string insert" {
    const s = str_from("Helo", 4);
    str_insert(s, 2, "l", 1);
    try std.testing.expectEqual(@as(usize, 5), str_size(s));
    try std.testing.expect(mem.eql(u8, str_data(s)[0..5], "Hello"));
    str_free(s);
}

test "string index_of_from" {
    const s = str_from("abcabcabc", 9);
    try std.testing.expectEqual(@as(i64, 1), str_index_of_from(s, "abc", 3, 1));
    try std.testing.expectEqual(@as(i64, 4), str_index_of_from(s, "abc", 3, 2));
    try std.testing.expectEqual(@as(i64, 7), str_index_of_from(s, "abc", 3, 5));
    try std.testing.expectEqual(@as(i64, -1), str_index_of_from(s, "abc", 3, 8));
    str_free(s);
}

test "string index_of_ci" {
    const s = str_from("Hello WORLD", 11);
    try std.testing.expectEqual(@as(i64, 1), str_index_of_ci(s, "hello", 5, 1));
    try std.testing.expectEqual(@as(i64, 7), str_index_of_ci(s, "world", 5, 1));
    try std.testing.expectEqual(@as(i64, -1), str_index_of_ci(s, "xyz", 3, 1));
    try std.testing.expectEqual(@as(i64, 7), str_index_of_ci(s, "WORLD", 5, 4));
    str_free(s);
}

test "string find_all" {
    const s = str_from("ring is ring and ring", 21);
    const r = str_find_all(s, "ring", 4);
    try std.testing.expectEqual(@as(c_int, 3), stz_find_result_count(r));
    try std.testing.expectEqual(@as(i64, 1), stz_find_result_get(r, 0));
    try std.testing.expectEqual(@as(i64, 9), stz_find_result_get(r, 1));
    try std.testing.expectEqual(@as(i64, 18), stz_find_result_get(r, 2));
    stz_find_result_free(r);

    // Not found
    const r2 = str_find_all(s, "xyz", 3);
    try std.testing.expectEqual(@as(c_int, 0), stz_find_result_count(r2));
    stz_find_result_free(r2);
    str_free(s);
}

test "string find_all_ci" {
    const s = str_from("Ring RING ring", 14);
    const r = str_find_all_ci(s, "ring", 4);
    try std.testing.expectEqual(@as(c_int, 3), stz_find_result_count(r));
    try std.testing.expectEqual(@as(i64, 1), stz_find_result_get(r, 0));
    try std.testing.expectEqual(@as(i64, 6), stz_find_result_get(r, 1));
    try std.testing.expectEqual(@as(i64, 11), stz_find_result_get(r, 2));
    stz_find_result_free(r);
    str_free(s);
}

test "string count_of_ci" {
    const s = str_from("Hello hello HELLO hElLo", 23);
    try std.testing.expectEqual(@as(c_int, 4), str_count_of_ci(s, "hello", 5));
    try std.testing.expectEqual(@as(c_int, 0), str_count_of_ci(s, "xyz", 3));
    str_free(s);
}

test "string last_index_of_ci" {
    const s = str_from("abc-ABC-Abc", 11);
    try std.testing.expectEqual(@as(i64, 9), str_last_index_of_ci(s, "abc", 3));
    try std.testing.expectEqual(@as(i64, -1), str_last_index_of_ci(s, "xyz", 3));
    str_free(s);
}

test "string starts_with_ci" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_starts_with_ci(s, "hello", 5));
    try std.testing.expectEqual(@as(c_int, 1), str_starts_with_ci(s, "HELLO", 5));
    try std.testing.expectEqual(@as(c_int, 0), str_starts_with_ci(s, "world", 5));
    str_free(s);
}

test "string ends_with_ci" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_ends_with_ci(s, "world", 5));
    try std.testing.expectEqual(@as(c_int, 1), str_ends_with_ci(s, "WORLD", 5));
    try std.testing.expectEqual(@as(c_int, 0), str_ends_with_ci(s, "hello", 5));
    str_free(s);
}

test "string contains_ci" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_contains_ci(s, "WORLD", 5));
    try std.testing.expectEqual(@as(c_int, 1), str_contains_ci(s, "hello", 5));
    try std.testing.expectEqual(@as(c_int, 0), str_contains_ci(s, "xyz", 3));
    str_free(s);
}

test "string split_count_ci" {
    const s = str_from("oneABCtwoabcthree", 17);
    try std.testing.expectEqual(@as(c_int, 3), str_split_count_ci(s, "abc", 3));
    str_free(s);
}

test "string split_get_ci" {
    const s = str_from("oneABCtwoAbCthree", 17);
    const p0 = str_split_get_ci(s, "abc", 3, 0);
    try std.testing.expect(mem.eql(u8, str_data(p0)[0..str_size(p0)], "one"));
    str_free(p0);
    const p1 = str_split_get_ci(s, "abc", 3, 1);
    try std.testing.expect(mem.eql(u8, str_data(p1)[0..str_size(p1)], "two"));
    str_free(p1);
    const p2 = str_split_get_ci(s, "abc", 3, 2);
    try std.testing.expect(mem.eql(u8, str_data(p2)[0..str_size(p2)], "three"));
    str_free(p2);
    str_free(s);
}

test "string replace_ci" {
    const s = str_from("Hello hello HELLO", 17);
    str_replace_ci(s, "hello", 5, "hi", 2);
    try std.testing.expectEqual(@as(usize, 8), str_size(s));
    try std.testing.expect(mem.eql(u8, str_data(s)[0..8], "hi hi hi"));
    str_free(s);
}

test "string count_of" {
    const s = str_from("abcabcabc", 9);
    try std.testing.expectEqual(@as(c_int, 3), str_count_of(s, "abc", 3));
    try std.testing.expectEqual(@as(c_int, 0), str_count_of(s, "xyz", 3));
    str_free(s);
}

test "string byte_to_cp" {
    // "caf\xC3\xA9" = c(0) a(1) f(2) e-acute(3,4 bytes -> cp 3)
    const s = str_from("caf\xC3\xA9", 5);
    try std.testing.expectEqual(@as(i64, 1), str_byte_to_cp(s, 0));
    try std.testing.expectEqual(@as(i64, 2), str_byte_to_cp(s, 1));
    try std.testing.expectEqual(@as(i64, 3), str_byte_to_cp(s, 2));
    try std.testing.expectEqual(@as(i64, 4), str_byte_to_cp(s, 3));
    str_free(s);
}

test "string replace_range" {
    const s = str_from("Hello World", 11);
    const r = str_replace_range(s, 5, 1, "_beautiful_", 11);
    try std.testing.expectEqual(@as(usize, 21), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..21], "Hello_beautiful_World"));
    str_free(r);
    str_free(s);
}

test "string replace_range at edges" {
    const s = str_from("abc", 3);
    const r1 = str_replace_range(s, 0, 1, "X", 1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..3], "Xbc"));
    str_free(r1);
    const r2 = str_replace_range(s, 2, 1, "Z", 1);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..3], "abZ"));
    str_free(r2);
    str_free(s);
}

test "string split_count" {
    const s = str_from("a:b:c", 5);
    try std.testing.expectEqual(@as(c_int, 3), str_split_count(s, ":", 1));
    str_free(s);
}

test "string split_get" {
    const s = str_from("one::two::three", 15);
    const p0 = str_split_get(s, "::", 2, 0);
    try std.testing.expect(mem.eql(u8, str_data(p0)[0..str_size(p0)], "one"));
    str_free(p0);
    const p1 = str_split_get(s, "::", 2, 1);
    try std.testing.expect(mem.eql(u8, str_data(p1)[0..str_size(p1)], "two"));
    str_free(p1);
    const p2 = str_split_get(s, "::", 2, 2);
    try std.testing.expect(mem.eql(u8, str_data(p2)[0..str_size(p2)], "three"));
    str_free(p2);
    str_free(s);
}

// ─── Unicode codepoint-position tests ───

test "find_all unicode codepoint positions" {
    // "bullet heart bullet bullet bullet bullet heart bullet bullet"
    // Each char is 3 bytes (U+2022=E2 80 A2, U+2665=E2 99 A5)
    // String: bullet(0) heart(1) bullet(2) bullet(3) bullet(4) bullet(5) heart(6) bullet(7) bullet(8)
    const str = "\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2\xe2\x80\xa2\xe2\x80\xa2\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2\xe2\x80\xa2";
    const s = str_from(str, 27);
    try std.testing.expectEqual(@as(usize, 9), str_count(s));

    // Find heart (E2 99 A5) -- should be at codepoint positions 2 and 7 (1-based)
    const r = str_find_all(s, "\xe2\x99\xa5", 3);
    try std.testing.expectEqual(@as(c_int, 2), stz_find_result_count(r));
    try std.testing.expectEqual(@as(i64, 2), stz_find_result_get(r, 0));
    try std.testing.expectEqual(@as(i64, 7), stz_find_result_get(r, 1));
    stz_find_result_free(r);

    // Find "bullet heart bullet" (9 bytes) -- at codepoint positions 1 and 6 (1-based)
    const sub = "\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2";
    const r2 = str_find_all(s, sub, 9);
    try std.testing.expectEqual(@as(c_int, 2), stz_find_result_count(r2));
    try std.testing.expectEqual(@as(i64, 1), stz_find_result_get(r2, 0));
    try std.testing.expectEqual(@as(i64, 6), stz_find_result_get(r2, 1));
    stz_find_result_free(r2);

    str_free(s);
}

test "index_of unicode codepoint position" {
    // "cafe" with e-acute: "caf\xC3\xA9X" -- 5 bytes, 4 codepoints + X
    const s = str_from("caf\xC3\xA9X", 6);
    try std.testing.expectEqual(@as(usize, 5), str_count(s));
    // 'X' is at byte 5 but codepoint position 5 (1-based)
    try std.testing.expectEqual(@as(i64, 5), str_index_of(s, "X", 1));
    str_free(s);
}

test "last_index_of unicode" {
    // Two hearts in multibyte string
    const str = "\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2\xe2\x99\xa5";
    const s = str_from(str, 12); // 4 chars, 12 bytes
    try std.testing.expectEqual(@as(usize, 4), str_count(s));
    // Last heart at codepoint position 4 (1-based)
    try std.testing.expectEqual(@as(i64, 4), str_last_index_of(s, "\xe2\x99\xa5", 3));
    str_free(s);
}

test "nth_char unicode" {
    const str = "\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2";
    const s = str_from(str, 9); // 3 chars
    // nth_char(2) should be heart (1-based: position 2)
    const ch = str_nth_char(s, 2);
    try std.testing.expectEqual(@as(usize, 3), str_size(ch));
    try std.testing.expect(mem.eql(u8, str_data(ch)[0..3], "\xe2\x99\xa5"));
    str_free(ch);
    str_free(s);
}

test "slice unicode" {
    // "bullet heart bullet bullet heart" = 5 chars
    const str = "\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2\xe2\x80\xa2\xe2\x99\xa5";
    const s = str_from(str, 15);
    // slice(2, 3) = chars at positions 2,3,4 = heart bullet bullet (1-based start)
    const sl = str_slice(s, 2, 3);
    try std.testing.expectEqual(@as(usize, 9), str_size(sl));
    try std.testing.expect(mem.eql(u8, str_data(sl)[0..3], "\xe2\x99\xa5"));
    str_free(sl);
    str_free(s);
}

test "reverse ascii" {
    const s = str_from("hello", 5);
    const r = str_reverse(s);
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..5], "olleh"));
    str_free(r);
    str_free(s);
}

test "reverse unicode" {
    // ABC where A=bullet(3b), B=heart(3b), C=bullet(3b)
    const str = "\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2";
    const s = str_from(str, 9);
    const r = str_reverse(s);
    // reversed = C B A = bullet heart bullet (same bytes, different order)
    try std.testing.expectEqual(@as(usize, 9), str_size(r));
    // First char should be the LAST original char (bullet)
    try std.testing.expect(mem.eql(u8, str_data(r)[0..3], "\xe2\x80\xa2"));
    // Second char should be heart
    try std.testing.expect(mem.eql(u8, str_data(r)[3..6], "\xe2\x99\xa5"));
    // Third char should be bullet
    try std.testing.expect(mem.eql(u8, str_data(r)[6..9], "\xe2\x80\xa2"));
    str_free(r);
    str_free(s);
}

test "reverse mixed ascii unicode" {
    // "aBC" where a='a'(1b), B=heart(3b), C='z'(1b)
    const s = str_from("a\xe2\x99\xa5z", 5);
    const r = str_reverse(s);
    // reversed = "z heart a"
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..1], "z"));
    try std.testing.expect(mem.eql(u8, str_data(r)[1..4], "\xe2\x99\xa5"));
    try std.testing.expect(mem.eql(u8, str_data(r)[4..5], "a"));
    str_free(r);
    str_free(s);
}

test "repeat" {
    const s = str_from("ab", 2);
    const r = str_repeat(s, 3);
    try std.testing.expectEqual(@as(usize, 6), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..6], "ababab"));
    str_free(r);
    str_free(s);
}

test "repeat unicode" {
    // heart = 3 bytes
    const s = str_from("\xe2\x99\xa5", 3);
    const r = str_repeat(s, 4);
    try std.testing.expectEqual(@as(usize, 12), str_size(r));
    try std.testing.expectEqual(@as(usize, 4), str_count(r));
    str_free(r);
    str_free(s);
}

test "repeat zero" {
    const s = str_from("hello", 5);
    const r = str_repeat(s, 0);
    try std.testing.expectEqual(@as(usize, 0), str_size(r));
    str_free(r);
    str_free(s);
}

test "pad_left ascii" {
    const s = str_from("hi", 2);
    const r = str_pad_left(s, 5, ".", 1);
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..5], "...hi"));
    str_free(r);
    str_free(s);
}

test "pad_left unicode fill" {
    // Pad "ab" to 5 codepoints using heart (3 bytes each)
    const s = str_from("ab", 2);
    const r = str_pad_left(s, 5, "\xe2\x99\xa5", 3);
    // Result: heart heart heart a b = 3*3 + 2 = 11 bytes, 5 codepoints
    try std.testing.expectEqual(@as(usize, 11), str_size(r));
    try std.testing.expectEqual(@as(usize, 5), str_count(r));
    // First 9 bytes = 3 hearts
    try std.testing.expect(mem.eql(u8, str_data(r)[0..3], "\xe2\x99\xa5"));
    try std.testing.expect(mem.eql(u8, str_data(r)[9..11], "ab"));
    str_free(r);
    str_free(s);
}

test "pad_left no padding needed" {
    const s = str_from("hello", 5);
    const r = str_pad_left(s, 3, " ", 1);
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..5], "hello"));
    str_free(r);
    str_free(s);
}

test "pad_right ascii" {
    const s = str_from("hi", 2);
    const r = str_pad_right(s, 5, ".", 1);
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..5], "hi..."));
    str_free(r);
    str_free(s);
}

test "pad_right unicode content" {
    // heart(3b) padded right to 4 codepoints with spaces
    const s = str_from("\xe2\x99\xa5", 3);
    const r = str_pad_right(s, 4, " ", 1);
    // Result: heart + 3 spaces = 3 + 3 = 6 bytes, 4 codepoints
    try std.testing.expectEqual(@as(usize, 6), str_size(r));
    try std.testing.expectEqual(@as(usize, 4), str_count(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..3], "\xe2\x99\xa5"));
    try std.testing.expect(mem.eql(u8, str_data(r)[3..6], "   "));
    str_free(r);
    str_free(s);
}

test "remove_range ascii" {
    const s = str_from("hello world", 11);
    // Remove "lo " (codepoints at positions 4,5,6 = 1-based)
    const r = str_remove_range(s, 4, 3);
    try std.testing.expectEqual(@as(usize, 8), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..8], "helworld"));
    str_free(r);
    str_free(s);
}

test "remove_range unicode" {
    // "a heart b" = a(1b) heart(3b) b(1b) = 3 codepoints
    const s = str_from("a\xe2\x99\xa5b", 5);
    // Remove heart (position 2, count 1) -- 1-based
    const r = str_remove_range(s, 2, 1);
    try std.testing.expectEqual(@as(usize, 2), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..2], "ab"));
    str_free(r);
    str_free(s);
}

test "trim_left" {
    const s = str_from("  \thello", 8);
    const r = str_trim_left(s);
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..5], "hello"));
    str_free(r);
    str_free(s);
}

test "trim_right" {
    const s = str_from("hello  \t", 8);
    const r = str_trim_right(s);
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..5], "hello"));
    str_free(r);
    str_free(s);
}

test "trim_left preserves unicode" {
    // spaces + heart
    const s = str_from("  \xe2\x99\xa5", 5);
    const r = str_trim_left(s);
    try std.testing.expectEqual(@as(usize, 3), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..3], "\xe2\x99\xa5"));
    str_free(r);
    str_free(s);
}

test "equals" {
    const a = str_from("hello", 5);
    const b = str_from("hello", 5);
    const c = str_from("world", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_equals(a, b));
    try std.testing.expectEqual(@as(c_int, 0), str_equals(a, c));
    str_free(a);
    str_free(b);
    str_free(c);
}

test "replace_first" {
    const s = str_from("aXbXc", 5);
    const r = str_replace_first(s, "X", 1, "YY", 2);
    try std.testing.expectEqual(@as(usize, 6), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..6], "aYYbXc"));
    str_free(r);
    str_free(s);
}

test "replace_last" {
    const s = str_from("aXbXc", 5);
    const r = str_replace_last(s, "X", 1, "ZZ", 2);
    try std.testing.expectEqual(@as(usize, 6), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..6], "aXbZZc"));
    str_free(r);
    str_free(s);
}

test "replace_nth" {
    const s = str_from("aXbXcXd", 7);
    // Replace 2nd occurrence
    const r = str_replace_nth(s, "X", 1, "**", 2, 2);
    try std.testing.expectEqual(@as(usize, 8), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..8], "aXb**cXd"));
    str_free(r);
    str_free(s);
}

test "replace_first no match" {
    const s = str_from("hello", 5);
    const r = str_replace_first(s, "Z", 1, "X", 1);
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..5], "hello"));
    str_free(r);
    str_free(s);
}

test "is_empty" {
    const empty = str_new();
    try std.testing.expectEqual(@as(c_int, 1), str_is_empty(empty));
    str_free(empty);

    const nonempty = str_from("x", 1);
    try std.testing.expectEqual(@as(c_int, 0), str_is_empty(nonempty));
    str_free(nonempty);
}

test "between" {
    const s = str_from("hello [world] end", 17);
    const r = str_between(s, "[", 1, "]", 1);
    try std.testing.expect(r != null);
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..5], "world"));
    str_free(r);
    str_free(s);
}

test "between multi-char delimiters" {
    const s = str_from("start<<content>>end", 19);
    const r = str_between(s, "<<", 2, ">>", 2);
    try std.testing.expect(r != null);
    try std.testing.expectEqual(@as(usize, 7), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..7], "content"));
    str_free(r);
    str_free(s);
}

test "between not found" {
    const s = str_from("hello world", 11);
    const r = str_between(s, "[", 1, "]", 1);
    try std.testing.expect(r == null);
    str_free(s);
}

test "is_numeric" {
    const num = str_from("12345", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_is_numeric(num));
    str_free(num);

    const mixed = str_from("12a45", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_is_numeric(mixed));
    str_free(mixed);

    const empty = str_new();
    try std.testing.expectEqual(@as(c_int, 0), str_is_numeric(empty));
    str_free(empty);
}

test "is_alpha" {
    const alpha = str_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_is_alpha(alpha));
    str_free(alpha);

    const mixed = str_from("Hello1", 6);
    try std.testing.expectEqual(@as(c_int, 0), str_is_alpha(mixed));
    str_free(mixed);

    // Unicode letters
    const uni = str_from("caf\xC3\xA9", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_is_alpha(uni));
    str_free(uni);
}

test "count_chars_of_type letters" {
    const s = str_from("Hello 123!", 10);
    // Type 0 = letters: H,e,l,l,o = 5
    try std.testing.expectEqual(@as(c_int, 5), str_count_chars_of_type(s, 0));
    // Type 1 = digits: 1,2,3 = 3
    try std.testing.expectEqual(@as(c_int, 3), str_count_chars_of_type(s, 1));
    // Type 2 = whitespace: 1 space
    try std.testing.expectEqual(@as(c_int, 1), str_count_chars_of_type(s, 2));
    str_free(s);
}

test "find_nth" {
    const s = str_from("aXbXcXd", 7);
    // 1st X at position 2 (1-based)
    try std.testing.expectEqual(@as(i64, 2), str_find_nth(s, "X", 1, 1));
    // 2nd X at position 4
    try std.testing.expectEqual(@as(i64, 4), str_find_nth(s, "X", 1, 2));
    // 3rd X at position 6
    try std.testing.expectEqual(@as(i64, 6), str_find_nth(s, "X", 1, 3));
    // 4th X doesn't exist
    try std.testing.expectEqual(@as(i64, -1), str_find_nth(s, "X", 1, 4));
    str_free(s);
}

test "find_nth unicode" {
    // "heart bullet heart bullet heart" = 5 chars
    const str = "\xe2\x99\xa5\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2\xe2\x99\xa5";
    const s = str_from(str, 15);
    // 1st heart at position 1 (1-based)
    try std.testing.expectEqual(@as(i64, 1), str_find_nth(s, "\xe2\x99\xa5", 3, 1));
    // 2nd heart at position 3
    try std.testing.expectEqual(@as(i64, 3), str_find_nth(s, "\xe2\x99\xa5", 3, 2));
    // 3rd heart at position 5
    try std.testing.expectEqual(@as(i64, 5), str_find_nth(s, "\xe2\x99\xa5", 3, 3));
    str_free(s);
}

test "remove_all" {
    const s = str_from("aXbXcXd", 7);
    const r = str_remove_all(s, "X", 1);
    try std.testing.expectEqual(@as(usize, 4), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..4], "abcd"));
    str_free(r);
    str_free(s);
}

test "remove_all multi-byte" {
    // Remove heart from "a heart b heart c"
    const s = str_from("a\xe2\x99\xa5b\xe2\x99\xa5c", 9);
    const r = str_remove_all(s, "\xe2\x99\xa5", 3);
    try std.testing.expectEqual(@as(usize, 3), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..3], "abc"));
    str_free(r);
    str_free(s);
}

test "lines_count" {
    const s1 = str_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_lines_count(s1));
    str_free(s1);

    const s2 = str_from("a\nb\nc", 5);
    try std.testing.expectEqual(@as(c_int, 3), str_lines_count(s2));
    str_free(s2);

    const s3 = str_new();
    try std.testing.expectEqual(@as(c_int, 0), str_lines_count(s3));
    str_free(s3);
}

test "is_palindrome ascii" {
    const s1 = str_from("racecar", 7);
    try std.testing.expectEqual(@as(c_int, 1), str_is_palindrome(s1));
    str_free(s1);

    const s2 = str_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_is_palindrome(s2));
    str_free(s2);

    const s3 = str_from("a", 1);
    try std.testing.expectEqual(@as(c_int, 1), str_is_palindrome(s3));
    str_free(s3);
}

test "is_palindrome unicode" {
    // heart bullet heart = palindrome
    const str = "\xe2\x99\xa5\xe2\x80\xa2\xe2\x99\xa5";
    const s = str_from(str, 9);
    try std.testing.expectEqual(@as(c_int, 1), str_is_palindrome(s));
    str_free(s);
}

test "concat" {
    const h1 = str_from("Hello", 5);
    const h2 = str_from(" World", 6);
    const r = str_concat(h1, h2);
    try std.testing.expectEqual(@as(usize, 11), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..11], "Hello World"));
    str_free(r);
    str_free(h1);
    str_free(h2);
}

test "is_ascii" {
    const ascii = str_from("Hello 123!", 10);
    try std.testing.expectEqual(@as(c_int, 1), str_is_ascii(ascii));
    str_free(ascii);

    const uni = str_from("caf\xC3\xA9", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_is_ascii(uni));
    str_free(uni);
}

test "remove_char_at" {
    const s = str_from("abcde", 5);
    // Remove 'c' at position 3 (1-based)
    const r = str_remove_char_at(s, 3);
    try std.testing.expectEqual(@as(usize, 4), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..4], "abde"));
    str_free(r);
    str_free(s);
}

test "char_type_at" {
    const s = str_from("A1 z!", 5);
    try std.testing.expectEqual(@as(c_int, 3), str_char_type_at(s, 1)); // 'A' = upper
    try std.testing.expectEqual(@as(c_int, 1), str_char_type_at(s, 2)); // '1' = digit
    try std.testing.expectEqual(@as(c_int, 2), str_char_type_at(s, 3)); // ' ' = space
    try std.testing.expectEqual(@as(c_int, 4), str_char_type_at(s, 4)); // 'z' = lower
    try std.testing.expectEqual(@as(c_int, 5), str_char_type_at(s, 5)); // '!' = punct
    str_free(s);
}

test "find_chars_of_type letters" {
    const s = str_from("a1b2c", 5);
    const r = str_find_chars_of_type(s, 0); // letters
    try std.testing.expectEqual(@as(c_int, 3), stz_find_result_count(r));
    try std.testing.expectEqual(@as(i64, 1), stz_find_result_get(r, 0)); // 'a'
    try std.testing.expectEqual(@as(i64, 3), stz_find_result_get(r, 1)); // 'b'
    try std.testing.expectEqual(@as(i64, 5), stz_find_result_get(r, 2)); // 'c'
    stz_find_result_free(r);
    str_free(s);
}

test "find_chars_of_type digits" {
    const s = str_from("a1b2c", 5);
    const r = str_find_chars_of_type(s, 1); // digits
    try std.testing.expectEqual(@as(c_int, 2), stz_find_result_count(r));
    try std.testing.expectEqual(@as(i64, 2), stz_find_result_get(r, 0)); // '1'
    try std.testing.expectEqual(@as(i64, 4), stz_find_result_get(r, 1)); // '2'
    stz_find_result_free(r);
    str_free(s);
}

test "extract_chars_of_type letters" {
    const s = str_from("H3ll0 W0rld!", 12);
    const r = str_extract_chars_of_type(s, 0); // letters
    // "H3ll0 W0rld!" -> letters: H, l, l, W, r, l, d = 7
    try std.testing.expectEqual(@as(usize, 7), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..7], "HllWrld"));
    str_free(r);
    str_free(s);
}

test "extract_chars_of_type digits" {
    const s = str_from("abc123def456", 12);
    const r = str_extract_chars_of_type(s, 1); // digits
    try std.testing.expectEqual(@as(usize, 6), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..6], "123456"));
    str_free(r);
    str_free(s);
}

test "is_uppercase" {
    const s1 = str_from("HELLO", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_is_uppercase(s1));
    str_free(s1);

    const s2 = str_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_is_uppercase(s2));
    str_free(s2);

    const s3 = str_from("HELLO 123!", 10);
    try std.testing.expectEqual(@as(c_int, 1), str_is_uppercase(s3));
    str_free(s3);

    const s4 = str_from("123", 3);
    try std.testing.expectEqual(@as(c_int, 0), str_is_uppercase(s4));
    str_free(s4);
}

test "is_lowercase" {
    const s1 = str_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_is_lowercase(s1));
    str_free(s1);

    const s2 = str_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_is_lowercase(s2));
    str_free(s2);

    const s3 = str_from("hello 123!", 10);
    try std.testing.expectEqual(@as(c_int, 1), str_is_lowercase(s3));
    str_free(s3);
}

test "is_whitespace" {
    const s1 = str_from("   ", 3);
    try std.testing.expectEqual(@as(c_int, 1), str_is_whitespace(s1));
    str_free(s1);

    const s2 = str_from(" a ", 3);
    try std.testing.expectEqual(@as(c_int, 0), str_is_whitespace(s2));
    str_free(s2);

    const s3 = str_from("", 0);
    try std.testing.expectEqual(@as(c_int, 0), str_is_whitespace(s3));
    str_free(s3);
}

test "word_count" {
    const s1 = str_from("hello world", 11);
    try std.testing.expectEqual(@as(c_int, 2), str_word_count(s1));
    str_free(s1);

    const s2 = str_from("  hello   world  ", 17);
    try std.testing.expectEqual(@as(c_int, 2), str_word_count(s2));
    str_free(s2);

    const s3 = str_from("one", 3);
    try std.testing.expectEqual(@as(c_int, 1), str_word_count(s3));
    str_free(s3);

    const s4 = str_from("", 0);
    try std.testing.expectEqual(@as(c_int, 0), str_word_count(s4));
    str_free(s4);
}

test "is_only_type" {
    const s1 = str_from("abc", 3);
    try std.testing.expectEqual(@as(c_int, 1), str_is_only_type(s1, 0)); // letters
    try std.testing.expectEqual(@as(c_int, 0), str_is_only_type(s1, 1)); // digits
    str_free(s1);

    const s2 = str_from("123", 3);
    try std.testing.expectEqual(@as(c_int, 1), str_is_only_type(s2, 1)); // digits
    try std.testing.expectEqual(@as(c_int, 0), str_is_only_type(s2, 0)); // letters
    str_free(s2);

    const s3 = str_from("   ", 3);
    try std.testing.expectEqual(@as(c_int, 1), str_is_only_type(s3, 2)); // space
    str_free(s3);
}

test "trim" {
    const s1 = str_from("  hello  ", 9);
    const r1 = str_trim(s1);
    try std.testing.expectEqual(@as(usize, 5), str_size(r1));
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..5], "hello"));
    str_free(r1);
    str_free(s1);

    const s2 = str_from("hello", 5);
    const r2 = str_trim(s2);
    try std.testing.expectEqual(@as(usize, 5), str_size(r2));
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..5], "hello"));
    str_free(r2);
    str_free(s2);

    const s3 = str_from("   ", 3);
    const r3 = str_trim(s3);
    try std.testing.expectEqual(@as(usize, 0), str_size(r3));
    str_free(r3);
    str_free(s3);
}

test "swap_case" {
    const s1 = str_from("Hello World", 11);
    const r1 = str_swap_case(s1);
    try std.testing.expectEqual(@as(usize, 11), str_size(r1));
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..11], "hELLO wORLD"));
    str_free(r1);
    str_free(s1);

    const s2 = str_from("123", 3);
    const r2 = str_swap_case(s2);
    try std.testing.expectEqual(@as(usize, 3), str_size(r2));
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..3], "123"));
    str_free(r2);
    str_free(s2);
}

test "remove_chars_of_type" {
    const s1 = str_from("Hello 123 World!", 16);
    // Remove digits
    const r1 = str_remove_chars_of_type(s1, 1);
    try std.testing.expectEqual(@as(usize, 13), str_size(r1));
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..13], "Hello  World!"));
    str_free(r1);
    // Remove spaces
    const r2 = str_remove_chars_of_type(s1, 2);
    try std.testing.expectEqual(@as(usize, 14), str_size(r2));
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..14], "Hello123World!"));
    str_free(r2);
    // Remove punctuation
    const r3 = str_remove_chars_of_type(s1, 5);
    try std.testing.expectEqual(@as(usize, 15), str_size(r3));
    try std.testing.expect(mem.eql(u8, str_data(r3)[0..15], "Hello 123 World"));
    str_free(r3);
    str_free(s1);
}

test "unique_chars" {
    const s = str_from("aabbcc", 6);
    const u = str_unique_chars(s);
    try std.testing.expectEqual(@as(usize, 3), str_size(u));
    try std.testing.expect(mem.eql(u8, str_data(u)[0..3], "abc"));
    str_free(u);
    str_free(s);

    const s_hello = str_from("Hello", 5);
    const u_hello = str_unique_chars(s_hello);
    try std.testing.expectEqual(@as(usize, 4), str_size(u_hello));
    try std.testing.expect(mem.eql(u8, str_data(u_hello)[0..4], "Helo"));
    str_free(u_hello);
    str_free(s_hello);
}

test "unique_char_count" {
    const s = str_from("aabbcc", 6);
    try std.testing.expectEqual(@as(c_int, 3), str_unique_char_count(s));
    str_free(s);

    const s_hello = str_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 4), str_unique_char_count(s_hello));
    str_free(s_hello);
}

test "remove_all_ci" {
    const s = str_from("Hello HELLO hello", 17);
    const r = str_remove_all_ci(s, "hello", 5);
    try std.testing.expectEqual(@as(usize, 2), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..2], "  "));
    str_free(r);
    str_free(s);
}

test "is_alpha_only" {
    const s1 = str_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_is_alpha_only(s1));
    str_free(s1);

    const s2 = str_from("Hello123", 8);
    try std.testing.expectEqual(@as(c_int, 0), str_is_alpha_only(s2));
    str_free(s2);
}

test "is_alnum" {
    const s1 = str_from("Hello123", 8);
    try std.testing.expectEqual(@as(c_int, 1), str_is_alnum(s1));
    str_free(s1);

    const s2 = str_from("Hello 123", 9);
    try std.testing.expectEqual(@as(c_int, 0), str_is_alnum(s2));
    str_free(s2);

    const s3 = str_from("abc", 3);
    try std.testing.expectEqual(@as(c_int, 1), str_is_alnum(s3));
    str_free(s3);
}

test "contains_char" {
    const s = str_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_contains_char(s, 'H'));
    try std.testing.expectEqual(@as(c_int, 1), str_contains_char(s, 'o'));
    try std.testing.expectEqual(@as(c_int, 0), str_contains_char(s, 'Z'));
    str_free(s);
}

test "between_nth" {
    const s = str_from("[a] [b] [c]", 11);
    const r0 = str_between_nth(s, "[", 1, "]", 1, 0);
    try std.testing.expect(r0 != null);
    try std.testing.expect(mem.eql(u8, str_data(r0)[0..1], "a"));
    str_free(r0);

    const r1 = str_between_nth(s, "[", 1, "]", 1, 1);
    try std.testing.expect(r1 != null);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..1], "b"));
    str_free(r1);

    const r2 = str_between_nth(s, "[", 1, "]", 1, 2);
    try std.testing.expect(r2 != null);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..1], "c"));
    str_free(r2);

    const r3 = str_between_nth(s, "[", 1, "]", 1, 3);
    try std.testing.expect(r3 == null);
    str_free(s);
}

test "count_between" {
    const s = str_from("[a] [b] [c]", 11);
    try std.testing.expectEqual(@as(c_int, 3), str_count_between(s, "[", 1, "]", 1));
    str_free(s);

    const s2 = str_from("no brackets", 11);
    try std.testing.expectEqual(@as(c_int, 0), str_count_between(s2, "[", 1, "]", 1));
    str_free(s2);
}

test "replace_char_at" {
    const s = str_from("Hello", 5);
    const r = str_replace_char_at(s, 1, "J", 1);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..5], "Jello"));
    str_free(r);

    // Replace with multi-byte
    const r2 = str_replace_char_at(s, 5, "!", 1);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..5], "Hell!"));
    str_free(r2);

    // Replace with empty (deletion)
    const r3 = str_replace_char_at(s, 1, "", 0);
    try std.testing.expectEqual(@as(usize, 4), str_size(r3));
    try std.testing.expect(mem.eql(u8, str_data(r3)[0..4], "ello"));
    str_free(r3);

    str_free(s);
}

test "levenshtein" {
    const s1 = str_from("kitten", 6);
    const s2 = str_from("sitting", 7);
    try std.testing.expectEqual(@as(c_int, 3), str_levenshtein(s1, s2));
    str_free(s1);
    str_free(s2);

    const s3 = str_from("hello", 5);
    const s4 = str_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_levenshtein(s3, s4));
    str_free(s3);
    str_free(s4);

    const s5 = str_from("", 0);
    const s6 = str_from("abc", 3);
    try std.testing.expectEqual(@as(c_int, 3), str_levenshtein(s5, s6));
    str_free(s5);
    str_free(s6);
}

test "is_title_case" {
    const s1 = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_is_title_case(s1));
    str_free(s1);

    const s2 = str_from("hello world", 11);
    try std.testing.expectEqual(@as(c_int, 0), str_is_title_case(s2));
    str_free(s2);

    const s3 = str_from("HELLO", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_is_title_case(s3));
    str_free(s3);

    const s4 = str_from("A", 1);
    try std.testing.expectEqual(@as(c_int, 1), str_is_title_case(s4));
    str_free(s4);
}

test "line_at" {
    const s = str_from("line1\nline2\nline3", 17);
    const l0 = str_line_at(s, 0);
    try std.testing.expect(mem.eql(u8, str_data(l0)[0..5], "line1"));
    str_free(l0);

    const l1 = str_line_at(s, 1);
    try std.testing.expect(mem.eql(u8, str_data(l1)[0..5], "line2"));
    str_free(l1);

    const l2 = str_line_at(s, 2);
    try std.testing.expect(mem.eql(u8, str_data(l2)[0..5], "line3"));
    str_free(l2);

    try std.testing.expect(str_line_at(s, 3) == null);
    str_free(s);

    // CRLF
    const s2 = str_from("a\r\nb\r\nc", 7);
    try std.testing.expectEqual(@as(c_int, 3), str_lines_split_count(s2));
    const la = str_line_at(s2, 0);
    try std.testing.expect(mem.eql(u8, str_data(la)[0..1], "a"));
    str_free(la);
    str_free(s2);
}

test "simplify" {
    const s1 = str_from("  hello   world  ", 17);
    const r1 = str_simplify(s1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..11], "hello world"));
    try std.testing.expectEqual(@as(usize, 11), str_size(r1));
    str_free(r1);
    str_free(s1);

    // Tabs and newlines
    const s2 = str_from("\thello\n\n  world\r\n", 18);
    const r2 = str_simplify(s2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..11], "hello world"));
    str_free(r2);
    str_free(s2);
}

test "starts_with_digit_letter" {
    const s1 = str_from("123abc", 6);
    try std.testing.expectEqual(@as(c_int, 1), str_starts_with_digit(s1));
    try std.testing.expectEqual(@as(c_int, 0), str_starts_with_letter(s1));
    str_free(s1);

    const s2 = str_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_starts_with_digit(s2));
    try std.testing.expectEqual(@as(c_int, 1), str_starts_with_letter(s2));
    str_free(s2);
}

test "ends_with_digit_letter" {
    const s1 = str_from("abc123", 6);
    try std.testing.expectEqual(@as(c_int, 1), str_ends_with_digit(s1));
    try std.testing.expectEqual(@as(c_int, 0), str_ends_with_letter(s1));
    str_free(s1);

    const s2 = str_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_ends_with_digit(s2));
    try std.testing.expectEqual(@as(c_int, 1), str_ends_with_letter(s2));
    str_free(s2);
}

// ─── IsWord: letters, digits, underscore, hyphen ───

// str_is_word -> string/inspect.zig

// ─── CountLeadingChar / CountTrailingChar ───

pub fn str_count_leading_char(handle: StzStringHandle, codepoint: u32) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    var off: usize = 0;
    var count: c_int = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        if (cp_val != codepoint) break;
        count += 1;
        off += cp_len;
    }
    return count;
}

pub fn str_count_trailing_char(handle: StzStringHandle, codepoint: u32) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (buf.len == 0) return 0;

    // Walk from the end backwards through UTF-8 sequences
    var count: c_int = 0;
    var pos: usize = buf.len;
    while (pos > 0) {
        // Find start of previous codepoint
        var start = pos - 1;
        while (start > 0 and (buf[start] & 0xC0) == 0x80) {
            start -= 1;
        }
        const cp_len = pos - start;
        const cp_val = std.unicode.utf8Decode(buf[start..pos]) catch break;
        _ = cp_len;
        if (cp_val != codepoint) break;
        count += 1;
        pos = start;
    }
    return count;
}

// ─── IsNumericString: all digits, optional leading +/- ───

// str_is_numeric_string -> string/inspect.zig

// URL encode/decode -> string/encode.zig

// str_char_at_to_string -> string/extract.zig

// ─── SpacifyChars: "abc" → "a b c" (codepoint-aware) ───

pub fn str_spacify(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (buf.len == 0) {
        const result = gpa.create(StzString) catch return null;
        result.* = StzString.init();
        return result;
    }

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    var off: usize = 0;
    var first = true;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        if (!first) {
            result.data.append(gpa, ' ') catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
        }
        result.data.appendSlice(gpa, buf[off .. off + cp_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
        first = false;
        off += cp_len;
    }
    return result;
}

// ─── NumberOfBytesPerChar: returns list as "1 1 2 3" for mixed-byte chars ───

pub fn str_bytes_per_char(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    var off: usize = 0;
    var first = true;
    var num_buf: [4]u8 = undefined;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        if (!first) {
            result.data.append(gpa, ' ') catch {
                result.deinit();
                gpa.destroy(result);
                return null;
            };
        }
        // cp_len is 1..4, write as ASCII digit
        num_buf[0] = '0' + @as(u8, @intCast(cp_len));
        result.data.append(gpa, num_buf[0]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
        first = false;
        off += cp_len;
    }
    return result;
}

// ─── Tests for new functions ───

test "is_word" {
    const s1 = str_from("hello-world_123", 15);
    try std.testing.expectEqual(@as(c_int, 1), str_is_word(s1));
    str_free(s1);

    const s2 = str_from("hello world", 11);
    try std.testing.expectEqual(@as(c_int, 0), str_is_word(s2));
    str_free(s2);

    const s3 = str_from("", 0);
    try std.testing.expectEqual(@as(c_int, 0), str_is_word(s3));
    str_free(s3);
}

test "count_leading_trailing_char" {
    const s1 = str_from("   hello", 8);
    try std.testing.expectEqual(@as(c_int, 3), str_count_leading_char(s1, ' '));
    try std.testing.expectEqual(@as(c_int, 0), str_count_trailing_char(s1, ' '));
    str_free(s1);

    const s2 = str_from("hello...", 8);
    try std.testing.expectEqual(@as(c_int, 0), str_count_leading_char(s2, '.'));
    try std.testing.expectEqual(@as(c_int, 3), str_count_trailing_char(s2, '.'));
    str_free(s2);
}

test "is_numeric_string" {
    const s1 = str_from("12345", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_is_numeric_string(s1));
    str_free(s1);

    const s2 = str_from("+42", 3);
    try std.testing.expectEqual(@as(c_int, 1), str_is_numeric_string(s2));
    str_free(s2);

    const s3 = str_from("-7", 2);
    try std.testing.expectEqual(@as(c_int, 1), str_is_numeric_string(s3));
    str_free(s3);

    const s4 = str_from("12.5", 4);
    try std.testing.expectEqual(@as(c_int, 0), str_is_numeric_string(s4));
    str_free(s4);

    const s5 = str_from("", 0);
    try std.testing.expectEqual(@as(c_int, 0), str_is_numeric_string(s5));
    str_free(s5);
}

test "url_encode_decode" {
    const s1 = str_from("hello world", 11);
    const enc = str_url_encode(s1);
    try std.testing.expect(mem.eql(u8, str_data(enc)[0..@intCast(str_size(enc))], "hello%20world"));

    const dec = str_url_decode(enc);
    try std.testing.expect(mem.eql(u8, str_data(dec)[0..@intCast(str_size(dec))], "hello world"));

    str_free(dec);
    str_free(enc);
    str_free(s1);
}

test "char_at_to_string" {
    const s1 = str_from("Hello", 5);
    const ch = str_char_at_to_string(s1, 1);
    try std.testing.expect(ch != null);
    try std.testing.expect(mem.eql(u8, str_data(ch)[0..@intCast(str_size(ch))], "H"));
    str_free(ch);
    str_free(s1);
}

test "spacify" {
    const s1 = str_from("abc", 3);
    const sp = str_spacify(s1);
    try std.testing.expect(mem.eql(u8, str_data(sp)[0..@intCast(str_size(sp))], "a b c"));
    str_free(sp);
    str_free(s1);
}

test "bytes_per_char" {
    const s1 = str_from("ab", 2);
    const bp = str_bytes_per_char(s1);
    try std.testing.expect(mem.eql(u8, str_data(bp)[0..@intCast(str_size(bp))], "1 1"));
    str_free(bp);
    str_free(s1);
}

// ─── IsHexString: all chars are 0-9, a-f, A-F, optional 0x prefix ───

// str_is_hex_string -> string/inspect.zig

// ─── IsBinaryString: all chars are 0 or 1, optional 0b prefix ───

// str_is_binary_string -> string/inspect.zig

// ─── IsOctalString: all chars are 0-7, optional 0o prefix ───

// str_is_octal_string -> string/inspect.zig

// str_word_at, isWhitespace -> string/split.zig

// str_center -> string/trim.zig

// str_remove_consecutive_duplicates -> string/replace.zig

// ─── Tests for new batch ───

test "is_hex_string" {
    const s1 = str_from("0xFF", 4);
    try std.testing.expectEqual(@as(c_int, 1), str_is_hex_string(s1));
    str_free(s1);

    const s2 = str_from("deadBEEF", 8);
    try std.testing.expectEqual(@as(c_int, 1), str_is_hex_string(s2));
    str_free(s2);

    const s3 = str_from("0xGG", 4);
    try std.testing.expectEqual(@as(c_int, 0), str_is_hex_string(s3));
    str_free(s3);
}

test "is_binary_string" {
    const s1 = str_from("0b1010", 6);
    try std.testing.expectEqual(@as(c_int, 1), str_is_binary_string(s1));
    str_free(s1);

    const s2 = str_from("1100", 4);
    try std.testing.expectEqual(@as(c_int, 1), str_is_binary_string(s2));
    str_free(s2);

    const s3 = str_from("1020", 4);
    try std.testing.expectEqual(@as(c_int, 0), str_is_binary_string(s3));
    str_free(s3);
}

test "is_octal_string" {
    const s1 = str_from("0o777", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_is_octal_string(s1));
    str_free(s1);

    const s2 = str_from("0o89", 4);
    try std.testing.expectEqual(@as(c_int, 0), str_is_octal_string(s2));
    str_free(s2);
}

test "word_at" {
    const s1 = str_from("hello world foo", 15);
    const w0 = str_word_at(s1, 0);
    try std.testing.expect(mem.eql(u8, str_data(w0)[0..@intCast(str_size(w0))], "hello"));
    str_free(w0);

    const w2 = str_word_at(s1, 2);
    try std.testing.expect(mem.eql(u8, str_data(w2)[0..@intCast(str_size(w2))], "foo"));
    str_free(w2);

    const w3 = str_word_at(s1, 3);
    try std.testing.expectEqual(@as(StzStringHandle, null), w3);
    str_free(s1);
}

test "center" {
    const s1 = str_from("hi", 2);
    const c1 = str_center(s1, 6, ' ');
    try std.testing.expect(mem.eql(u8, str_data(c1)[0..@intCast(str_size(c1))], "  hi  "));
    str_free(c1);
    str_free(s1);
}

test "remove_consecutive_duplicates" {
    const s1 = str_from("aabbcc", 6);
    const r1 = str_remove_consecutive_duplicates(s1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "abc"));
    str_free(r1);
    str_free(s1);

    const s2 = str_from("mississippi", 11);
    const r2 = str_remove_consecutive_duplicates(s2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "misisipi"));
    str_free(r2);
    str_free(s2);
}

// str_substring -> string/extract.zig

// str_replace_substring -> string/replace.zig

// ─── HasPrefix / HasSuffix with count (how many times a prefix/suffix repeats) ───

pub fn str_prefix_count(handle: StzStringHandle, prefix: [*c]const u8, prefix_len: usize) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (prefix == null or prefix_len == 0 or buf.len == 0) return 0;
    const pref = prefix[0..prefix_len];

    var count: c_int = 0;
    var off: usize = 0;
    while (off + prefix_len <= buf.len) {
        if (mem.eql(u8, buf[off .. off + prefix_len], pref)) {
            count += 1;
            off += prefix_len;
        } else {
            break;
        }
    }
    return count;
}

pub fn str_suffix_count(handle: StzStringHandle, suffix: [*c]const u8, suffix_len: usize) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (suffix == null or suffix_len == 0 or buf.len == 0) return 0;
    const suf = suffix[0..suffix_len];

    var count: c_int = 0;
    var pos: usize = buf.len;
    while (pos >= suffix_len) {
        if (mem.eql(u8, buf[pos - suffix_len .. pos], suf)) {
            count += 1;
            pos -= suffix_len;
        } else {
            break;
        }
    }
    return count;
}

// ─── CommonPrefix / CommonSuffix between two strings ───

pub fn str_common_prefix(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) StzStringHandle {
    const s1 = h1 orelse return null;
    const s2 = h2 orelse return null;
    const b1 = s1.slice();
    const b2 = s2.slice();

    var off: usize = 0;
    var last_cp_end: usize = 0;
    while (off < b1.len and off < b2.len) {
        const len1 = std.unicode.utf8ByteSequenceLength(b1[off]) catch break;
        const len2 = std.unicode.utf8ByteSequenceLength(b2[off]) catch break;
        if (len1 != len2 or off + len1 > b1.len or off + len2 > b2.len) break;
        if (!mem.eql(u8, b1[off .. off + len1], b2[off .. off + len2])) break;
        off += len1;
        last_cp_end = off;
    }

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    if (last_cp_end > 0) {
        result.data.appendSlice(gpa, b1[0..last_cp_end]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

pub fn str_common_suffix(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) StzStringHandle {
    const s1 = h1 orelse return null;
    const s2 = h2 orelse return null;
    const b1 = s1.slice();
    const b2 = s2.slice();

    if (b1.len == 0 or b2.len == 0) {
        const result = gpa.create(StzString) catch return null;
        result.* = StzString.init();
        return result;
    }

    // Walk backwards byte by byte, but verify codepoint boundaries
    var i: usize = 0;
    const min_len = @min(b1.len, b2.len);
    while (i < min_len) {
        if (b1[b1.len - 1 - i] != b2[b2.len - 1 - i]) break;
        i += 1;
    }

    // Adjust to codepoint boundary
    const start = b1.len - i;
    var adjusted_start = start;
    while (adjusted_start < b1.len and (b1[adjusted_start] & 0xC0) == 0x80) {
        adjusted_start += 1;
    }

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    if (adjusted_start < b1.len) {
        result.data.appendSlice(gpa, b1[adjusted_start..]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

// ─── Tests for new batch ───

test "substring" {
    const s1 = str_from("Hello World", 11);
    const sub = str_substring(s1, 1, 5);
    try std.testing.expect(mem.eql(u8, str_data(sub)[0..@intCast(str_size(sub))], "Hello"));
    str_free(sub);

    const sub2 = str_substring(s1, 7, 11);
    try std.testing.expect(mem.eql(u8, str_data(sub2)[0..@intCast(str_size(sub2))], "World"));
    str_free(sub2);
    str_free(s1);
}

test "replace_substring" {
    const s1 = str_from("Hello World", 11);
    const r1 = str_replace_substring(s1, 7, 11, "Zig", 3);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "Hello Zig"));
    str_free(r1);
    str_free(s1);
}

test "prefix_suffix_count" {
    const s1 = str_from("ababab", 6);
    try std.testing.expectEqual(@as(c_int, 3), str_prefix_count(s1, "ab", 2));
    str_free(s1);

    const s2 = str_from("xyzxyzxyz", 9);
    try std.testing.expectEqual(@as(c_int, 3), str_suffix_count(s2, "xyz", 3));
    str_free(s2);
}

test "common_prefix_suffix" {
    const s1 = str_from("hello world", 11);
    const s2 = str_from("hello there", 11);
    const cp = str_common_prefix(s1, s2);
    try std.testing.expect(mem.eql(u8, str_data(cp)[0..@intCast(str_size(cp))], "hello "));
    str_free(cp);
    str_free(s2);
    str_free(s1);

    const s3 = str_from("testing", 7);
    const s4 = str_from("working", 7);
    const cs = str_common_suffix(s3, s4);
    try std.testing.expect(mem.eql(u8, str_data(cs)[0..@intCast(str_size(cs))], "ing"));
    str_free(cs);
    str_free(s4);
    str_free(s3);
}

// ─── SortChars: sort codepoints ascending/descending ───

pub fn str_sort_chars_asc(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (buf.len == 0) {
        const result = gpa.create(StzString) catch return null;
        result.* = StzString.init();
        return result;
    }

    // Collect codepoints
    var cps: std.ArrayList(u21) = .{};
    defer cps.deinit(gpa);
    var off: usize = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        cps.append(gpa, cp_val) catch return null;
        off += cp_len;
    }

    // Sort ascending
    std.mem.sort(u21, cps.items, {}, std.sort.asc(u21));

    // Rebuild UTF-8
    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    var enc_buf: [4]u8 = undefined;
    for (cps.items) |cp| {
        const enc_len = std.unicode.utf8Encode(cp, &enc_buf) catch continue;
        result.data.appendSlice(gpa, enc_buf[0..enc_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

pub fn str_sort_chars_desc(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (buf.len == 0) {
        const result = gpa.create(StzString) catch return null;
        result.* = StzString.init();
        return result;
    }

    var cps: std.ArrayList(u21) = .{};
    defer cps.deinit(gpa);
    var off: usize = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        cps.append(gpa, cp_val) catch return null;
        off += cp_len;
    }

    // Sort descending
    std.mem.sort(u21, cps.items, {}, std.sort.desc(u21));

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    var enc_buf: [4]u8 = undefined;
    for (cps.items) |cp| {
        const enc_len = std.unicode.utf8Encode(cp, &enc_buf) catch continue;
        result.data.appendSlice(gpa, enc_buf[0..enc_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

// str_find_all_char -> string/find.zig

// Hash -> string/encode.zig

// ─── CountChar: count occurrences of a specific codepoint ───

pub fn str_count_char(handle: StzStringHandle, codepoint: u32) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    var count: c_int = 0;
    var off: usize = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        if (cp_val == codepoint) count += 1;
        off += cp_len;
    }
    return count;
}

// str_replace_char -> string/replace.zig

// ─── Copy ───

pub fn str_copy(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    result.data.appendSlice(gpa, buf) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    return result;
}

// ─── Compare ───

pub fn str_compare(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) c_int {
    const s1 = h1 orelse return -2;
    const s2 = h2 orelse return -2;
    const buf1 = s1.slice();
    const buf2 = s2.slice();

    // Codepoint-by-codepoint comparison
    var off1: usize = 0;
    var off2: usize = 0;
    while (off1 < buf1.len and off2 < buf2.len) {
        const len1 = std.unicode.utf8ByteSequenceLength(buf1[off1]) catch return -2;
        const len2 = std.unicode.utf8ByteSequenceLength(buf2[off2]) catch return -2;
        if (off1 + len1 > buf1.len or off2 + len2 > buf2.len) return -2;
        const cp1 = std.unicode.utf8Decode(buf1[off1..][0..len1]) catch return -2;
        const cp2 = std.unicode.utf8Decode(buf2[off2..][0..len2]) catch return -2;
        if (cp1 < cp2) return -1;
        if (cp1 > cp2) return 1;
        off1 += len1;
        off2 += len2;
    }
    if (off1 < buf1.len) return 1; // s1 longer
    if (off2 < buf2.len) return -1; // s2 longer
    return 0;
}

// str_remove_first_occurrence -> string/replace.zig

// str_remove_last_occurrence -> string/replace.zig

// ─── IsCharsSortedAsc ───

// str_is_chars_sorted_asc -> string/inspect.zig

// ─── IsCharsSortedDesc ───

// str_is_chars_sorted_desc -> string/inspect.zig

// str_remove_nth_occurrence -> string/replace.zig

// ─── RepeatChar ───

pub fn str_repeat_char(cp: u32, count: c_int) callconv(.c) StzStringHandle {
    if (count <= 0) return str_new();

    var char_bytes: [4]u8 = undefined;
    const cp21: u21 = @intCast(cp);
    const char_len = std.unicode.utf8Encode(cp21, &char_bytes) catch return null;

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    const n: usize = @intCast(count);
    result.data.ensureTotalCapacity(gpa, n * char_len) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    for (0..n) |_| {
        result.data.appendSlice(gpa, char_bytes[0..char_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

// str_insert_before_each -> string/replace.zig

// str_insert_after_each -> string/replace.zig

// ─── Truncate ───

pub fn str_truncate(handle: StzStringHandle, max_cp: c_int, ellipsis: [*c]const u8, ell_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (max_cp <= 0) return str_new();

    // Count codepoints
    var cp_count: usize = 0;
    var off: usize = 0;
    var cut_off: usize = 0;
    const max: usize = @intCast(max_cp);
    while (off < buf.len) {
        if (cp_count == max) {
            cut_off = off;
            break;
        }
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        off += cp_len;
        cp_count += 1;
    }

    // If string fits, return copy
    if (cp_count <= max and off >= buf.len) return str_copy(handle);

    // Need truncation
    if (cut_off == 0) cut_off = off;
    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    result.data.appendSlice(gpa, buf[0..cut_off]) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    if (ellipsis != null and ell_len > 0) {
        result.data.appendSlice(gpa, ellipsis[0..ell_len]) catch {
            result.deinit();
            gpa.destroy(result);
            return null;
        };
    }
    return result;
}

// ─── WrapAt ───

pub fn str_wrap_at(handle: StzStringHandle, width: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (width <= 0) return str_copy(handle);
    const w: usize = @intCast(width);

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    var line_cp: usize = 0;
    var last_space_result_pos: ?usize = null;
    var off: usize = 0;

    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;

        if (cp_val == '\n') {
            result.data.append(gpa, '\n') catch break;
            off += cp_len;
            line_cp = 0;
            last_space_result_pos = null;
            continue;
        }

        if (cp_val == ' ') {
            last_space_result_pos = result.data.items.len;
        }

        result.data.appendSlice(gpa, buf[off .. off + cp_len]) catch break;
        off += cp_len;
        line_cp += 1;

        if (line_cp >= w and last_space_result_pos != null) {
            // Replace last space with newline
            result.data.items[last_space_result_pos.?] = '\n';
            line_cp = result.data.items.len - last_space_result_pos.? - 1;
            last_space_result_pos = null;
        }
    }
    return result;
}

// str_remove_prefix -> string/replace.zig

// str_remove_suffix -> string/replace.zig

// ─── EnsurePrefix ───

pub fn str_ensure_prefix(handle: StzStringHandle, prefix: [*c]const u8, prefix_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (prefix == null or prefix_len == 0) return str_copy(handle);
    const pfx: []const u8 = prefix[0..prefix_len];
    if (mem.startsWith(u8, buf, pfx)) return str_copy(handle);

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    result.data.appendSlice(gpa, pfx) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    result.data.appendSlice(gpa, buf) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    return result;
}

// ─── EnsureSuffix ───

pub fn str_ensure_suffix(handle: StzStringHandle, suffix: [*c]const u8, suffix_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (suffix == null or suffix_len == 0) return str_copy(handle);
    const sfx: []const u8 = suffix[0..suffix_len];
    if (mem.endsWith(u8, buf, sfx)) return str_copy(handle);

    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();
    result.data.appendSlice(gpa, buf) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    result.data.appendSlice(gpa, sfx) catch {
        result.deinit();
        gpa.destroy(result);
        return null;
    };
    return result;
}

// str_squeeze_char -> string/trim.zig

// str_capitalize_first -> string/transform.zig

// str_decapitalize_first -> string/transform.zig

// str_zfill -> string/trim.zig

// str_tab_expand -> string/trim.zig

// ─── CountOverlapping ───
// Count overlapping occurrences of needle in string

pub fn str_count_overlapping(handle: StzStringHandle, needle: [*c]const u8, needle_len: usize) callconv(.c) c_int {
    const s = handle orelse return 0;
    const buf = s.slice();
    if (needle == null or needle_len == 0 or needle_len > buf.len) return 0;
    const ndl: []const u8 = needle[0..needle_len];

    var count: c_int = 0;
    var pos: usize = 0;
    while (pos + needle_len <= buf.len) {
        if (mem.eql(u8, buf[pos..][0..needle_len], ndl)) {
            count += 1;
            // Move by 1 byte for overlapping (not by needle_len)
            pos += 1;
        } else {
            pos += 1;
        }
    }
    return count;
}

// str_replace_at -> string/replace.zig

// ─── CharFrequency ───
// Returns "char:count" pairs separated by newlines, e.g. "a:3\nb:2\n"

pub fn str_char_frequency(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const buf = s.slice();
    if (buf.len == 0) return str_new();

    // Collect codepoints and count them
    var cps: std.ArrayList(u21) = .{};
    defer cps.deinit(gpa);
    var counts: std.ArrayList(usize) = .{};
    defer counts.deinit(gpa);

    var off: usize = 0;
    while (off < buf.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(buf[off]) catch break;
        if (off + cp_len > buf.len) break;
        const cp_val = std.unicode.utf8Decode(buf[off..][0..cp_len]) catch break;
        off += cp_len;

        // Find if already tracked
        var found = false;
        for (cps.items, 0..) |existing, i| {
            if (existing == cp_val) {
                counts.items[i] += 1;
                found = true;
                break;
            }
        }
        if (!found) {
            cps.append(gpa, cp_val) catch break;
            counts.append(gpa, 1) catch break;
        }
    }

    // Build result string
    const result = gpa.create(StzString) catch return null;
    result.* = StzString.init();

    for (cps.items, 0..) |cp_val, i| {
        var cp_bytes: [4]u8 = undefined;
        const cp_byte_len = std.unicode.utf8Encode(cp_val, &cp_bytes) catch continue;
        result.data.appendSlice(gpa, cp_bytes[0..cp_byte_len]) catch break;
        result.data.append(gpa, ':') catch break;

        // Number to string
        var num_buf: [20]u8 = undefined;
        const num_str = std.fmt.bufPrint(&num_buf, "{d}", .{counts.items[i]}) catch break;
        result.data.appendSlice(gpa, num_str) catch break;
        result.data.append(gpa, '\n') catch break;
    }
    return result;
}

// ─── ContainsAnyOf ───
// Check if string contains any of the characters in the given string

// str_contains_any_of -> string/inspect.zig

// ─── ContainsAllOf ───

// str_contains_all_of -> string/inspect.zig

// str_center_pad -> string/trim.zig

// ─── Only Letters / Digits ───

pub fn str_only_letters(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    const r = str_new() orelse return null;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch break;
        if (unicode.stz_unicode_is_letter(cp) != 0) {
            r.data.appendSlice(gpa, src[off..][0..cp_len]) catch { setError(.out_of_memory); };
        }
        off += cp_len;
    }
    return r;
}

pub fn str_only_digits(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    const r = str_new() orelse return null;

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp = std.unicode.utf8Decode(src[off..][0..cp_len]) catch break;
        if (unicode.stz_unicode_is_digit(cp) != 0) {
            r.data.appendSlice(gpa, src[off..][0..cp_len]) catch { setError(.out_of_memory); };
        }
        off += cp_len;
    }
    return r;
}

// str_remove_whitespace -> string/replace.zig

// (str_is_palindrome already defined above)

// ─── IsAlphanumeric ───

// str_is_alphanumeric -> string/inspect.zig

// str_ljust -> string/trim.zig
// str_rjust -> string/trim.zig

// (str_common_prefix already defined above)

// str_count_words, str_nth_word -> string/split.zig

// str_chars_between -> string/extract.zig

// str_indent -> string/trim.zig
// str_dedent -> string/trim.zig

// ─── CamelCase / SnakeCase / KebabCase ───

// str_to_camel_case -> string/transform.zig

// str_to_snake_case -> string/transform.zig

// str_to_kebab_case -> string/transform.zig

// Partition (str_partition, str_partition_after, str_rpartition, str_rpartition_after) -> string/split.zig

// str_squeeze -> string/trim.zig

// ─── IsDigit (all chars are digits) ───

// str_is_digit -> string/inspect.zig

// ─── StringMultiply (interleave) ───

/// Interleave: place separator between each codepoint. "abc" with "," => "a,b,c"
pub fn str_interleave(handle: StzStringHandle, sep: [*c]const u8, sep_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();
    if (src.len == 0) return str_new();

    const separator = if (sep_len > 0) sep[0..sep_len] else return str_from(src.ptr, src.len);
    const r = str_new() orelse return null;
    var first = true;
    var off: usize = 0;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;

        if (!first) {
            r.data.appendSlice(gpa, separator) catch { setError(.out_of_memory); };
        }
        r.data.appendSlice(gpa, src[off..][0..cp_len]) catch { setError(.out_of_memory); };
        first = false;
        off += cp_len;
    }
    return r;
}

// str_strip_chars -> string/replace.zig

// str_keep_chars -> string/replace.zig

// str_replace2 -> string/replace.zig

// ─── Surround ───

/// Wrap string with prefix and suffix: surround("hello", "[", "]") => "[hello]"
pub fn str_surround(handle: StzStringHandle, prefix: [*c]const u8, prefix_len: usize, suffix: [*c]const u8, suffix_len: usize) callconv(.c) StzStringHandle {
    const s = handle orelse return str_new();
    const src = s.slice();

    const r = str_new() orelse return null;
    if (prefix_len > 0) r.data.appendSlice(gpa, prefix[0..prefix_len]) catch { setError(.out_of_memory); };
    r.data.appendSlice(gpa, src) catch { setError(.out_of_memory); };
    if (suffix_len > 0) r.data.appendSlice(gpa, suffix[0..suffix_len]) catch { setError(.out_of_memory); };
    return r;
}

// str_replace_any_char -> string/replace.zig

// ─── CountMatches ───

/// Count how many codepoints in the string match any char in the `chars` set.
pub fn str_count_any_char(handle: StzStringHandle, chars: [*c]const u8, chars_len: usize) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0 or chars_len == 0) return 0;

    const charset = chars[0..chars_len];
    var count: c_int = 0;
    var off: usize = 0;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;

        var coff: usize = 0;
        while (coff < charset.len) {
            const c_len = std.unicode.utf8ByteSequenceLength(charset[coff]) catch break;
            if (coff + c_len > charset.len) break;
            if (c_len == cp_len and mem.eql(u8, src[off..][0..cp_len], charset[coff..][0..c_len])) {
                count += 1;
                break;
            }
            coff += c_len;
        }
        off += cp_len;
    }
    return count;
}

/// Rotate codepoints left by `n` positions. Negative n rotates right.
/// Returns new handle with rotated string.
pub fn str_rotate(handle: StzStringHandle, n: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return str_from(src.ptr, src.len);

    // Count codepoints
    var cp_count: usize = 0;
    var i: usize = 0;
    while (i < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[i]) catch break;
        if (i + cp_len > src.len) break;
        cp_count += 1;
        i += cp_len;
    }
    if (cp_count == 0) return str_from(src.ptr, src.len);

    // Normalize rotation amount
    const cpi: i64 = @intCast(cp_count);
    var rot: i64 = @rem(@as(i64, n), cpi);
    if (rot < 0) rot += cpi;
    if (rot == 0) return str_from(src.ptr, src.len);

    // Find byte offset of rotation point
    var off: usize = 0;
    var cp_idx: usize = 0;
    while (cp_idx < @as(usize, @intCast(rot)) and off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        off += cp_len;
        cp_idx += 1;
    }

    const result = str_new() orelse return null;
    result.data.appendSlice(gpa, src[off..]) catch {
        str_free(result);
        return null;
    };
    result.data.appendSlice(gpa, src[0..off]) catch {
        str_free(result);
        return null;
    };
    return result;
}

/// Repeat string to fill exactly `target_len` codepoints.
/// Returns new handle.
pub fn str_repeat_to_length(handle: StzStringHandle, target_len: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0 or target_len <= 0) return str_new();

    const target: usize = @intCast(target_len);

    // Count codepoints in source
    var cp_count: usize = 0;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        cp_count += 1;
        off += cp_len;
    }
    if (cp_count == 0) return str_new();

    const result = str_new() orelse return null;
    var written: usize = 0;
    while (written < target) {
        const remaining = target - written;
        if (remaining >= cp_count) {
            // Append full copy
            result.data.appendSlice(gpa, src) catch break;
            written += cp_count;
        } else {
            // Append partial: walk `remaining` codepoints
            var poff: usize = 0;
            var pidx: usize = 0;
            while (pidx < remaining and poff < src.len) {
                const plen = std.unicode.utf8ByteSequenceLength(src[poff]) catch break;
                if (poff + plen > src.len) break;
                poff += plen;
                pidx += 1;
            }
            result.data.appendSlice(gpa, src[0..poff]) catch break;
            written += remaining;
        }
    }
    return result;
}

// str_remove_between -> string/replace.zig

// str_is_blank -> string/inspect.zig

// str_to_pascal_case -> string/transform.zig

// str_is_identifier -> string/inspect.zig

// str_replace_between -> string/replace.zig

// str_contains_only -> string/inspect.zig

// str_capitalize_words -> string/transform.zig

/// Swap characters at two codepoint positions (INDEX_BASE convention). Returns new handle.
pub fn str_swap_chars(handle: StzStringHandle, pos1: c_int, pos2: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0 or pos1 < INDEX_BASE or pos2 < INDEX_BASE or pos1 == pos2) return str_from(src.ptr, src.len);

    const p1: usize = toInternal(@intCast(pos1));
    const p2: usize = toInternal(@intCast(pos2));

    // Build array of byte-offset ranges for each codepoint
    var offsets: [32768]struct { start: usize, len: usize } = undefined;
    var cp_count: usize = 0;
    var off: usize = 0;
    while (off < src.len and cp_count < 32768) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        offsets[cp_count] = .{ .start = off, .len = cp_len };
        cp_count += 1;
        off += cp_len;
    }

    if (p1 >= cp_count or p2 >= cp_count) return str_from(src.ptr, src.len);

    const result = str_new() orelse return null;
    var idx: usize = 0;
    while (idx < cp_count) {
        const actual = if (idx == p1) p2 else if (idx == p2) p1 else idx;
        const o = offsets[actual];
        result.data.appendSlice(gpa, src[o.start..][0..o.len]) catch break;
        idx += 1;
    }
    return result;
}

// Hex encode/decode -> string/encode.zig

/// Reverse the order of words in the string. Words are whitespace-delimited.
/// Returns new handle.
pub fn str_reverse_words(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return str_from(src.ptr, 0);

    // Collect word boundaries (start, end byte offsets)
    var words: [8192]struct { start: usize, end: usize } = undefined;
    var word_count: usize = 0;
    var off: usize = 0;
    var in_word = false;
    var word_start: usize = 0;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp_val: i32 = decodeCodepoint(src, off, cp_len);
        const is_space = unicode.stz_unicode_is_space(cp_val) != 0;

        if (!is_space and !in_word) {
            word_start = off;
            in_word = true;
        } else if (is_space and in_word) {
            if (word_count < 8192) {
                words[word_count] = .{ .start = word_start, .end = off };
                word_count += 1;
            }
            in_word = false;
        }
        off += cp_len;
    }
    if (in_word and word_count < 8192) {
        words[word_count] = .{ .start = word_start, .end = off };
        word_count += 1;
    }

    if (word_count == 0) return str_from(src.ptr, src.len);

    const result = str_new() orelse return null;
    var i: usize = word_count;
    while (i > 0) {
        i -= 1;
        if (i < word_count - 1) {
            result.data.appendSlice(gpa, " ") catch break;
        }
        const w = words[i];
        result.data.appendSlice(gpa, src[w.start..w.end]) catch break;
    }
    return result;
}

// str_collapse_spaces -> string/trim.zig

// str_is_anagram -> string/inspect.zig

/// Mask the string: replace middle characters with mask_char, keeping `keep` chars visible
/// at start and end. E.g. mask("hello@mail.com", '*', 2) -> "he*********om"
/// Returns new handle.
pub fn str_mask(handle: StzStringHandle, mask_char: [*c]const u8, mask_len: usize, keep: c_int) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0 or mask_len == 0) return str_from(src.ptr, src.len);

    const keep_n: usize = if (keep >= 0) @intCast(keep) else 0;
    const mask_s = mask_char[0..mask_len];

    // Count codepoints
    var cp_count: usize = 0;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        cp_count += 1;
        off += cp_len;
    }

    if (cp_count <= keep_n * 2) return str_from(src.ptr, src.len);

    const result = str_new() orelse return null;
    off = 0;
    var idx: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;

        if (idx < keep_n or idx >= cp_count - keep_n) {
            result.data.appendSlice(gpa, src[off..][0..cp_len]) catch break;
        } else {
            result.data.appendSlice(gpa, mask_s) catch break;
        }
        idx += 1;
        off += cp_len;
    }
    return result;
}

/// Count consecutive character runs (groups of identical adjacent chars).
/// E.g. "aabbbcc" has 3 runs: "aa", "bbb", "cc".
pub fn str_count_runs(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var runs: c_int = 1;
    var off: usize = 0;
    var prev_cp: i32 = -1;

    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const cp: i32 = decodeCodepoint(src, off, cp_len);
        if (prev_cp >= 0 and cp != prev_cp) {
            runs += 1;
        }
        prev_cp = cp;
        off += cp_len;
    }
    return runs;
}

/// Hamming distance: count positions where corresponding codepoints differ.
/// Strings must be same codepoint length; returns -1 if different lengths.
// Hamming distance -> string/nlp.zig

// str_remove_vowels -> string/replace.zig

/// Keep only ASCII vowels (a,e,i,o,u both cases). Returns new handle.
pub fn str_only_vowels(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return str_from(src.ptr, 0);

    const result = str_new() orelse return null;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1) {
            const c = src[off];
            if (c == 'a' or c == 'e' or c == 'i' or c == 'o' or c == 'u' or
                c == 'A' or c == 'E' or c == 'I' or c == 'O' or c == 'U')
            {
                result.data.appendSlice(gpa, src[off..][0..1]) catch break;
            }
        }
        off += cp_len;
    }
    return result;
}

// str_is_pangram -> string/inspect.zig

// ngram -> string/nlp.zig

/// Count ASCII consonants (letters that are not vowels). Case-insensitive.
pub fn str_count_consonants(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1) {
            const c = src[off];
            const lower = if (c >= 'A' and c <= 'Z') c + 32 else c;
            if (lower >= 'a' and lower <= 'z') {
                if (lower != 'a' and lower != 'e' and lower != 'i' and lower != 'o' and lower != 'u') {
                    count += 1;
                }
            }
        }
        off += cp_len;
    }
    return count;
}

// str_to_sentence_case -> string/transform.zig

// str_is_balanced -> string/inspect.zig

/// Convert to URL-friendly slug: lowercase, spaces/underscores to hyphens,
/// remove non-alphanumeric (except hyphens), collapse consecutive hyphens.
/// Returns new handle.
pub fn str_slug(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return str_from(src.ptr, 0);

    const result = str_new() orelse return null;
    var prev_hyphen = true; // suppress leading hyphen
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1) {
            const c = src[off];
            if (c >= 'A' and c <= 'Z') {
                result.data.appendSlice(gpa, &[_]u8{c + 32}) catch break;
                prev_hyphen = false;
            } else if ((c >= 'a' and c <= 'z') or (c >= '0' and c <= '9')) {
                result.data.appendSlice(gpa, &[_]u8{c}) catch break;
                prev_hyphen = false;
            } else if (c == ' ' or c == '_' or c == '-' or c == '\t') {
                if (!prev_hyphen) {
                    result.data.appendSlice(gpa, "-") catch break;
                    prev_hyphen = true;
                }
            }
            // else: skip non-alnum
        }
        // skip multi-byte codepoints for slug
        off += cp_len;
    }
    // Remove trailing hyphen
    const rsl = result.slice();
    if (rsl.len > 0 and rsl[rsl.len - 1] == '-') {
        _ = result.data.pop();
    }
    return result;
}

// str_chunk -> string/split.zig

/// Count ASCII vowels (a,e,i,o,u both cases).
pub fn str_count_vowels(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1) {
            const c = src[off];
            if (c == 'a' or c == 'e' or c == 'i' or c == 'o' or c == 'u' or
                c == 'A' or c == 'E' or c == 'I' or c == 'O' or c == 'U')
            {
                count += 1;
            }
        }
        off += cp_len;
    }
    return count;
}

/// Return the length of the longest run of consecutive identical codepoints.
pub fn str_longest_run(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var max_run: c_int = 1;
    var cur_run: c_int = 1;
    var prev_start: usize = 0;
    var prev_len: usize = 0;
    var off: usize = 0;
    var first = true;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (first) {
            first = false;
        } else {
            if (cp_len == prev_len and mem.eql(u8, src[off..][0..cp_len], src[prev_start..][0..prev_len])) {
                cur_run += 1;
                if (cur_run > max_run) max_run = cur_run;
            } else {
                cur_run = 1;
            }
        }
        prev_start = off;
        prev_len = cp_len;
        off += cp_len;
    }
    return max_run;
}

// str_trim_chars -> string/trim.zig

// str_is_email_like -> string/inspect.zig

/// Split camelCase/PascalCase into space-separated words.
/// E.g. "camelCaseString" -> "camel Case String"
/// Returns new handle.
pub fn str_camel_to_words(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return str_from(src.ptr, 0);

    const result = str_new() orelse return null;
    var i: usize = 0;
    while (i < src.len) {
        const c = src[i];
        // Insert space before uppercase that follows lowercase
        if (i > 0 and c >= 'A' and c <= 'Z') {
            const prev = src[i - 1];
            if (prev >= 'a' and prev <= 'z') {
                result.data.appendSlice(gpa, " ") catch break;
            } else if (prev >= 'A' and prev <= 'Z' and i + 1 < src.len and src[i + 1] >= 'a' and src[i + 1] <= 'z') {
                // ABCdef -> AB Cdef
                result.data.appendSlice(gpa, " ") catch break;
            }
        }
        result.data.appendSlice(gpa, src[i..][0..1]) catch break;
        i += 1;
    }
    return result;
}

/// Extract initials (first letter of each word). Words separated by spaces.
/// E.g. "Hello World" -> "HW", "united states of america" -> "usoa"
/// Returns new handle.
pub fn str_initials(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return str_from(src.ptr, 0);

    const result = str_new() orelse return null;
    var in_word = false;
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1 and (src[off] == ' ' or src[off] == '\t' or src[off] == '\n' or src[off] == '\r')) {
            in_word = false;
        } else {
            if (!in_word) {
                result.data.appendSlice(gpa, src[off..][0..cp_len]) catch break;
                in_word = true;
            }
        }
        off += cp_len;
    }
    return result;
}

// str_remove_duplicate_words -> string/replace.zig

// str_is_url_like -> string/inspect.zig

// HTML escape/unescape -> string/encode.zig

/// Count sentences (terminated by '.', '!', or '?').
pub fn str_count_sentences(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var count: c_int = 0;
    for (src) |c| {
        if (c == '.' or c == '!' or c == '?') count += 1;
    }
    return count;
}

/// Smart titlecase: capitalize words except small words (the, a, an, of, in, on, at, to, for, and, but, or, is).
/// First word is always capitalized. Returns new handle.
pub fn str_title_smart(handle: StzStringHandle) callconv(.c) StzStringHandle {
    const s = handle orelse return null;
    const src = s.slice();
    if (src.len == 0) return str_from(src.ptr, 0);

    const small_words = [_][]const u8{ "the", "a", "an", "of", "in", "on", "at", "to", "for", "and", "but", "or", "is" };

    const result = str_new() orelse return null;
    var off: usize = 0;
    var first_word = true;

    while (off < src.len) {
        // Skip spaces
        while (off < src.len and (src[off] == ' ' or src[off] == '\t')) {
            result.data.appendSlice(gpa, src[off..][0..1]) catch break;
            off += 1;
        }
        if (off >= src.len) break;

        // Find word end
        const word_start = off;
        while (off < src.len and src[off] != ' ' and src[off] != '\t') off += 1;
        const word = src[word_start..off];

        if (first_word or !isSmallWord(word, &small_words)) {
            // Capitalize first letter
            if (word.len > 0 and word[0] >= 'a' and word[0] <= 'z') {
                result.data.appendSlice(gpa, &[_]u8{word[0] - 32}) catch break;
                if (word.len > 1) result.data.appendSlice(gpa, word[1..]) catch break;
            } else {
                result.data.appendSlice(gpa, word) catch break;
            }
        } else {
            result.data.appendSlice(gpa, word) catch break;
        }
        first_word = false;
    }
    return result;
}

fn isSmallWord(word: []const u8, small_words: []const []const u8) bool {
    // Compare lowercase
    var buf: [16]u8 = undefined;
    if (word.len > 16) return false;
    for (word, 0..) |c, i| {
        buf[i] = if (c >= 'A' and c <= 'Z') c + 32 else c;
    }
    const lower = buf[0..word.len];
    for (small_words) |sw| {
        if (mem.eql(u8, lower, sw)) return true;
    }
    return false;
}

// str_remove_punctuation -> string/replace.zig

// str_is_float -> string/inspect.zig

/// Sum of all digit characters in the string. E.g. "a1b2c3" -> 6.
pub fn str_digit_sum(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var sum: c_int = 0;
    for (src) |c| {
        if (c >= '0' and c <= '9') sum += @as(c_int, c - '0');
    }
    return sum;
}

// str_to_alternating_case -> string/transform.zig

/// Count uppercase ASCII letters.
pub fn str_count_upper(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    for (src) |c| {
        if (c >= 'A' and c <= 'Z') count += 1;
    }
    return count;
}

/// Count lowercase ASCII letters.
pub fn str_count_lower(handle: StzStringHandle) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    for (src) |c| {
        if (c >= 'a' and c <= 'z') count += 1;
    }
    return count;
}

// str_is_camel_case -> string/inspect.zig

/// Return characters common to both strings (unique, in order of appearance in h1).
/// Returns new handle.
pub fn str_common_chars(h1: StzStringHandle, h2: StzStringHandle) callconv(.c) StzStringHandle {
    const s1 = h1 orelse return null;
    const s2 = h2 orelse return null;
    const src1 = s1.slice();
    const src2 = s2.slice();

    const result = str_new() orelse return null;
    var seen: [256]bool = [_]bool{false} ** 256;

    var off: usize = 0;
    while (off < src1.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src1[off]) catch break;
        if (off + cp_len > src1.len) break;
        if (cp_len == 1) {
            const c = src1[off];
            if (!seen[c]) {
                // Check if this char exists in src2
                for (src2) |c2| {
                    if (c2 == c) {
                        result.data.appendSlice(gpa, &[_]u8{c}) catch break;
                        seen[c] = true;
                        break;
                    }
                }
            }
        }
        off += cp_len;
    }
    return result;
}

// batch 7 ─────────────────────────────────────────────────────────

// str_count_lines -> string/split.zig

// str_is_snake_case -> string/inspect.zig

// str_is_kebab_case -> string/inspect.zig

/// Count unique (distinct) characters in the string.
pub export fn str_count_unique_chars(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    // For ASCII, use a 256-entry seen table; for multi-byte, count them separately
    var seen: [256]bool = [_]bool{false} ** 256;
    var count: c_int = 0;
    var multi_byte_count: c_int = 0;

    // Simple approach: for single-byte chars use the table, for multi-byte just count unique sequences
    // (limited to ASCII uniqueness for performance; multi-byte chars each counted as unique)
    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        if (cp_len == 1) {
            if (!seen[src[off]]) {
                seen[src[off]] = true;
                count += 1;
            }
        } else {
            // For multi-byte, do a naive check against previously seen multi-byte sequences
            // Simple: just count all multi-byte codepoints (approximation for ASCII-heavy use)
            multi_byte_count += 1;
        }
        off += cp_len;
    }
    return count + multi_byte_count;
}

// Caesar cipher -> string/encode.zig

// batch 8 ─────────────────────────────────────────────────────────

/// Mirror/reflect: "abc" -> "abccba"
pub export fn str_mirror(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;

    // Append original
    result.data.appendSlice(gpa, src) catch return result;
    // Append reversed
    var off: usize = src.len;
    while (off > 0) {
        // Walk backwards to find start of previous codepoint
        off -= 1;
        while (off > 0 and (src[off] & 0xC0) == 0x80) {
            off -= 1;
        }
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        result.data.appendSlice(gpa, src[off .. off + cp_len]) catch break;
        if (off == 0) break;
    }
    return result;
}

/// Repeat each character n times: "abc", 2 -> "aabbcc"
pub export fn str_repeat_each_char(handle: ?*StzString, n: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    if (n <= 0) return result;
    const count: usize = @intCast(n);

    var off: usize = 0;
    while (off < src.len) {
        const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
        if (off + cp_len > src.len) break;
        const ch = src[off .. off + cp_len];
        for (0..count) |_| {
            result.data.appendSlice(gpa, ch) catch break;
        }
        off += cp_len;
    }
    return result;
}

/// Check if string starts with any of the given prefixes (pipe-separated: "http|ftp|ssh")
// str_starts_with_any, str_ends_with_any -> string/find.zig

// Binary encode -> string/encode.zig

// batch 9 ─────────────────────────────────────────────────────────

/// Sort words alphabetically (case-sensitive). Words separated by spaces.
pub export fn str_sort_words(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;

    // Collect word boundaries
    var words: [256][2]usize = undefined; // [start, end] pairs, max 256 words
    var word_count: usize = 0;
    var i: usize = 0;
    while (i < src.len and word_count < 256) {
        // Skip spaces
        while (i < src.len and src[i] == ' ') : (i += 1) {}
        if (i >= src.len) break;
        const start = i;
        while (i < src.len and src[i] != ' ') : (i += 1) {}
        words[word_count] = .{ start, i };
        word_count += 1;
    }

    // Simple insertion sort on words
    var j: usize = 1;
    while (j < word_count) : (j += 1) {
        const key = words[j];
        var k: usize = j;
        while (k > 0) {
            const w_k = src[words[k - 1][0]..words[k - 1][1]];
            const w_key = src[key[0]..key[1]];
            if (mem.order(u8, w_k, w_key) == .gt) {
                words[k] = words[k - 1];
                k -= 1;
            } else break;
        }
        words[k] = key;
    }

    // Build result
    for (0..word_count) |idx| {
        if (idx > 0) result.data.appendSlice(gpa, " ") catch break;
        result.data.appendSlice(gpa, src[words[idx][0]..words[idx][1]]) catch break;
    }
    return result;
}

/// Keep only unique words (first occurrence preserved). Words separated by spaces.
pub export fn str_unique_words(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;

    // Collect words and track seen
    var seen_starts: [256]usize = undefined;
    var seen_ends: [256]usize = undefined;
    var seen_count: usize = 0;
    var first = true;

    var ii: usize = 0;
    while (ii < src.len) {
        while (ii < src.len and src[ii] == ' ') : (ii += 1) {}
        if (ii >= src.len) break;
        const start = ii;
        while (ii < src.len and src[ii] != ' ') : (ii += 1) {}
        const word = src[start..ii];

        // Check if already seen
        var found = false;
        for (0..seen_count) |si| {
            if (mem.eql(u8, src[seen_starts[si]..seen_ends[si]], word)) {
                found = true;
                break;
            }
        }
        if (!found) {
            if (!first) result.data.appendSlice(gpa, " ") catch break;
            result.data.appendSlice(gpa, word) catch break;
            if (seen_count < 256) {
                seen_starts[seen_count] = start;
                seen_ends[seen_count] = ii;
                seen_count += 1;
            }
            first = false;
        }
    }
    return result;
}

// Binary decode -> string/encode.zig

// str_swap_words -> string/split.zig

// Pig latin -> string/nlp.zig

// batch 10 ────────────────────────────────────────────────────────

/// Run-length encode: "aaabbc" -> "3a2b1c"
pub export fn str_run_length_encode(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    if (src.len == 0) return result;

    var i: usize = 0;
    while (i < src.len) {
        const ch = src[i];
        var count: usize = 1;
        while (i + count < src.len and src[i + count] == ch) : (count += 1) {}
        // Write count as digits
        var buf: [20]u8 = undefined;
        var digits: usize = 0;
        var n = count;
        while (n > 0) {
            buf[digits] = @intCast('0' + (n % 10));
            digits += 1;
            n /= 10;
        }
        // Reverse digits into result
        var d: usize = digits;
        while (d > 0) {
            d -= 1;
            result.data.appendSlice(gpa, &[_]u8{buf[d]}) catch break;
        }
        result.data.appendSlice(gpa, &[_]u8{ch}) catch break;
        i += count;
    }
    return result;
}

/// Run-length decode: "3a2b1c" -> "aaabbc"
pub export fn str_run_length_decode(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;

    var i: usize = 0;
    while (i < src.len) {
        // Parse number
        var count: usize = 0;
        while (i < src.len and src[i] >= '0' and src[i] <= '9') {
            count = count * 10 + (src[i] - '0');
            i += 1;
        }
        if (count == 0) count = 1;
        if (i >= src.len) break;
        const ch = src[i];
        i += 1;
        for (0..count) |_| {
            result.data.appendSlice(gpa, &[_]u8{ch}) catch break;
        }
    }
    return result;
}

/// Count paragraphs (separated by double newlines \n\n).
pub export fn str_count_paragraphs(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    if (src.len == 0) return 0;

    var count: c_int = 1;
    var i: usize = 0;
    while (i + 1 < src.len) {
        if (src[i] == '\n' and src[i + 1] == '\n') {
            count += 1;
            // Skip any additional consecutive newlines
            while (i + 1 < src.len and src[i + 1] == '\n') : (i += 1) {}
        }
        i += 1;
    }
    return count;
}

// Zigzag, Morse, Base64, XOR, Entropy -> string/encode.zig

/// Return the most frequent character as a single-char string. Ties: first in byte order.
pub export fn str_char_frequency_top(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    if (src.len == 0) return result;

    var freq: [256]u32 = [_]u32{0} ** 256;
    for (src) |c| {
        freq[c] += 1;
    }

    var max_idx: u8 = 0;
    var max_count: u32 = 0;
    for (0..256) |idx| {
        if (freq[idx] > max_count) {
            max_count = freq[idx];
            max_idx = @intCast(idx);
        }
    }
    result.data.appendSlice(gpa, &[_]u8{max_idx}) catch { setError(.out_of_memory); };
    return result;
}

// batch 12 ────────────────────────────────────────────────────────

// Jaccard similarity -> string/nlp.zig

/// Longest common prefix between two handles.
pub export fn str_longest_common_prefix(h1: ?*StzString, h2: ?*StzString) callconv(.c) ?*StzString {
    const s1 = h1 orelse return null;
    const s2 = h2 orelse return null;
    const src1 = s1.slice();
    const src2 = s2.slice();
    const result = str_new() orelse return null;

    const min_len = if (src1.len < src2.len) src1.len else src2.len;
    var i: usize = 0;
    while (i < min_len and src1[i] == src2[i]) : (i += 1) {}
    result.data.appendSlice(gpa, src1[0..i]) catch { setError(.out_of_memory); };
    return result;
}

/// Longest common suffix between two handles.
pub export fn str_longest_common_suffix(h1: ?*StzString, h2: ?*StzString) callconv(.c) ?*StzString {
    const s1 = h1 orelse return null;
    const s2 = h2 orelse return null;
    const src1 = s1.slice();
    const src2 = s2.slice();
    const result = str_new() orelse return null;

    const min_len = if (src1.len < src2.len) src1.len else src2.len;
    var i: usize = 0;
    while (i < min_len and src1[src1.len - 1 - i] == src2[src2.len - 1 - i]) : (i += 1) {}
    if (i > 0) result.data.appendSlice(gpa, src1[src1.len - i ..]) catch { setError(.out_of_memory); };
    return result;
}

/// Wrap string with prefix and suffix: wrap("hello", "[", "]") -> "[hello]"
pub export fn str_wrap_with(handle: ?*StzString, prefix: [*c]const u8, prefix_len: c_int, suffix: [*c]const u8, suffix_len: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    const plen: usize = if (prefix_len >= 0) @intCast(prefix_len) else 0;
    const slen: usize = if (suffix_len >= 0) @intCast(suffix_len) else 0;

    result.data.appendSlice(gpa, prefix[0..plen]) catch { setError(.out_of_memory); };
    result.data.appendSlice(gpa, src) catch { setError(.out_of_memory); };
    result.data.appendSlice(gpa, suffix[0..slen]) catch { setError(.out_of_memory); };
    return result;
}

// str_to_title_case_strict -> string/transform.zig

// batch 13 ────────────────────────────────────────────────────────

/// Hamming weight: count of 1-bits across all bytes.
pub export fn str_hamming_weight(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    for (src) |byte| {
        var b = byte;
        while (b != 0) {
            count += 1;
            b &= b - 1; // clear lowest set bit
        }
    }
    return count;
}

// str_is_palindrome_words -> string/inspect.zig

// str_remove_nth_word -> string/replace.zig

// str_insert_word_at -> string/replace.zig

// str_to_spongebob_case -> string/transform.zig

// batch 14 ────────────────────────────────────────────────────────

// str_between_first -> string/extract.zig

// str_to_dot_case -> string/transform.zig

/// Abbreviate: produce a string of at most max_len total characters.
/// If the string is longer, truncate to (max_len - 3) characters + "...".
/// If max_len <= 3, just return "..." truncated to max_len.
pub export fn str_abbreviate(handle: ?*StzString, max_len: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    const limit: usize = if (max_len >= 0) @intCast(max_len) else return result;

    // Count total codepoints
    const cp_count = utf8CodepointCount(src);

    if (cp_count <= limit) {
        result.data.appendSlice(gpa, src) catch { setError(.out_of_memory); };
    } else {
        // Truncate to (limit - 3) codepoints + "..."
        const text_len: usize = if (limit >= 3) limit - 3 else 0;
        var off: usize = 0;
        var cp_idx: usize = 0;
        while (off < src.len and cp_idx < text_len) {
            const cp_len = std.unicode.utf8ByteSequenceLength(src[off]) catch break;
            if (off + cp_len > src.len) break;
            off += cp_len;
            cp_idx += 1;
        }
        result.data.appendSlice(gpa, src[0..off]) catch { setError(.out_of_memory); };
        result.data.appendSlice(gpa, "...") catch { setError(.out_of_memory); };
    }
    return result;
}

/// Count non-overlapping occurrences of a substring.
pub export fn str_count_substring(handle: ?*StzString, needle: [*c]const u8, needle_len: c_int) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    const nlen: usize = if (needle_len > 0) @intCast(needle_len) else return 0;
    const ndl = needle[0..nlen];

    var count: c_int = 0;
    var i: usize = 0;
    while (i + nlen <= src.len) {
        if (mem.eql(u8, src[i .. i + nlen], ndl)) {
            count += 1;
            i += nlen;
        } else {
            i += 1;
        }
    }
    return count;
}

// str_to_path_case -> string/transform.zig

// ─── Batch 15: left_pad, right_pad, is_numeric, is_alpha, is_alphanumeric ───

// str_left_pad -> string/trim.zig
// str_right_pad -> string/trim.zig

// to_hex, from_hex -> string/encode.zig

// Soundex -> string/nlp.zig

// ─── Batch 16: vigenere_encrypt, atbash, count_words_matching, truncate_words, to_constant_case ───

// Vigenere, Atbash -> string/encode.zig

pub export fn str_count_words_matching(handle: ?*StzString, pattern_ptr: [*c]const u8, pattern_len: c_int) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    const plen: usize = if (pattern_len < 1) return 0 else @intCast(pattern_len);
    const pattern = pattern_ptr[0..plen];
    var count: c_int = 0;
    var pos: usize = 0;
    while (pos < src.len) {
        // skip spaces
        while (pos < src.len and src[pos] == ' ') pos += 1;
        if (pos >= src.len) break;
        const start = pos;
        while (pos < src.len and src[pos] != ' ') pos += 1;
        const word = src[start..pos];
        if (word.len == plen and mem.eql(u8, word, pattern)) count += 1;
    }
    return count;
}

pub export fn str_truncate_words(handle: ?*StzString, max_words: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const max: usize = if (max_words < 1) 0 else @intCast(max_words);
    const result = str_new() orelse return null;
    if (max == 0) return result;
    var word_count: usize = 0;
    var pos: usize = 0;
    var last_end: usize = 0;
    while (pos < src.len) {
        while (pos < src.len and src[pos] == ' ') pos += 1;
        if (pos >= src.len) break;
        if (word_count > 0) {
            // include the space before this word
        }
        const word_start = pos;
        _ = word_start;
        while (pos < src.len and src[pos] != ' ') pos += 1;
        word_count += 1;
        last_end = pos;
        if (word_count >= max) break;
    }
    if (last_end > 0) {
        // Find start: skip leading spaces
        var start: usize = 0;
        while (start < src.len and src[start] == ' ') start += 1;
        result.data.appendSlice(gpa, src[start..last_end]) catch { setError(.out_of_memory); };
    }
    return result;
}

// str_to_constant_case -> string/transform.zig

// ─── Batch 17: first_word, last_word, to_nato, commonality, diff_chars ───

// str_first_word, str_last_word -> string/split.zig

// NATO -> string/nlp.zig

pub export fn str_commonality(handle: ?*StzString, other: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const o = other orelse return 0;
    const src = s.slice();
    const oth = o.slice();
    // Count chars present in both (based on set intersection)
    var seen_src = [_]bool{false} ** 256;
    for (src) |c| seen_src[c] = true;
    var count: c_int = 0;
    var seen_counted = [_]bool{false} ** 256;
    for (oth) |c| {
        if (seen_src[c] and !seen_counted[c]) {
            count += 1;
            seen_counted[c] = true;
        }
    }
    return count;
}

pub export fn str_diff_chars(handle: ?*StzString, other: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const o = other orelse return null;
    const src = s.slice();
    const oth = o.slice();
    const result = str_new() orelse return null;
    // Chars in src not in other (unique set)
    var in_other = [_]bool{false} ** 256;
    for (oth) |c| in_other[c] = true;
    var added = [_]bool{false} ** 256;
    for (src) |c| {
        if (!in_other[c] and !added[c]) {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
            added[c] = true;
        }
    }
    return result;
}

// ─── Batch 18: rot47, is_isogram, reverse_each_word, count_digits, strip_tags ───

// ROT47 -> string/encode.zig

// str_is_isogram -> string/inspect.zig

pub export fn str_reverse_each_word(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    var pos: usize = 0;
    while (pos < src.len) {
        if (src[pos] == ' ') {
            result.data.appendSlice(gpa, &[_]u8{' '}) catch break;
            pos += 1;
        } else {
            const start = pos;
            while (pos < src.len and src[pos] != ' ') pos += 1;
            // Reverse the word
            var j: usize = pos;
            while (j > start) {
                j -= 1;
                result.data.appendSlice(gpa, &[_]u8{src[j]}) catch break;
            }
        }
    }
    return result;
}

pub export fn str_count_digits(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    for (src) |c| {
        if (c >= '0' and c <= '9') count += 1;
    }
    return count;
}

pub export fn str_strip_tags(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    var in_tag = false;
    for (src) |c| {
        if (c == '<') {
            in_tag = true;
        } else if (c == '>') {
            in_tag = false;
        } else if (!in_tag) {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
        }
    }
    return result;
}

// ─── Batch 19: to_slug, count_spaces, normalize_spaces, mask_email, pluralize ───

pub export fn str_to_slug(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    var prev_was_dash = false;
    for (src) |c| {
        if (c >= 'A' and c <= 'Z') {
            result.data.appendSlice(gpa, &[_]u8{c + 32}) catch break;
            prev_was_dash = false;
        } else if ((c >= 'a' and c <= 'z') or (c >= '0' and c <= '9')) {
            result.data.appendSlice(gpa, &[_]u8{c}) catch break;
            prev_was_dash = false;
        } else if (c == ' ' or c == '_' or c == '-' or c == '\t') {
            if (!prev_was_dash) {
                result.data.appendSlice(gpa, &[_]u8{'-'}) catch break;
                prev_was_dash = true;
            }
        }
        // skip other chars
    }
    // Remove trailing dash
    const rslice = result.slice();
    if (rslice.len > 0 and rslice[rslice.len - 1] == '-') {
        _ = result.data.pop();
    }
    return result;
}

pub export fn str_count_spaces(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var count: c_int = 0;
    for (src) |c| {
        if (c == ' ') count += 1;
    }
    return count;
}

// str_normalize_spaces -> string/trim.zig

// mask_email, pluralize -> string/nlp.zig

// ─── Batch 20: deduplicate_lines, remove_blank_lines, extract_numbers, extract_emails, quote ───

pub export fn str_deduplicate_lines(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    // Track seen lines — simple O(n^2) for correctness
    var line_starts: [1024]usize = undefined;
    var line_ends: [1024]usize = undefined;
    var line_count: usize = 0;
    // Parse lines
    var pos: usize = 0;
    var first = true;
    while (pos <= src.len and line_count < 1024) {
        const start = pos;
        while (pos < src.len and src[pos] != '\n') pos += 1;
        const end = pos;
        // Check if this line is a duplicate
        var is_dup = false;
        const line = src[start..end];
        for (0..line_count) |li| {
            const prev = src[line_starts[li]..line_ends[li]];
            if (prev.len == line.len and mem.eql(u8, prev, line)) {
                is_dup = true;
                break;
            }
        }
        if (!is_dup) {
            if (!first) result.data.appendSlice(gpa, "\n") catch { setError(.out_of_memory); };
            result.data.appendSlice(gpa, line) catch { setError(.out_of_memory); };
            line_starts[line_count] = start;
            line_ends[line_count] = end;
            line_count += 1;
            first = false;
        }
        if (pos < src.len) pos += 1 else break; // skip \n
    }
    return result;
}

// str_remove_blank_lines -> string/replace.zig

// extract_numbers, extract_emails -> string/nlp.zig

// Quote, Unquote, CSV field -> string/encode.zig

// ─── Batch 21: number_lines, hide, extract_words ───

pub export fn str_number_lines(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    var line_num: usize = 1;
    var pos: usize = 0;
    while (pos <= src.len) {
        // Write line number
        var buf: [12]u8 = undefined;
        const num_len = formatUsize(line_num, &buf);
        result.data.appendSlice(gpa, buf[0..num_len]) catch { setError(.out_of_memory); };
        result.data.appendSlice(gpa, ": ") catch { setError(.out_of_memory); };
        // Write line content
        const start = pos;
        while (pos < src.len and src[pos] != '\n') pos += 1;
        result.data.appendSlice(gpa, src[start..pos]) catch { setError(.out_of_memory); };
        if (pos < src.len) {
            result.data.appendSlice(gpa, "\n") catch { setError(.out_of_memory); };
            pos += 1;
            line_num += 1;
        } else break;
    }
    return result;
}

pub export fn str_hide(handle: ?*StzString, mask_char: u8, keep_first: c_int, keep_last: c_int) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    const kf: usize = if (keep_first < 0) 0 else @intCast(keep_first);
    const kl: usize = if (keep_last < 0) 0 else @intCast(keep_last);
    if (kf + kl >= src.len) {
        result.data.appendSlice(gpa, src) catch { setError(.out_of_memory); };
        return result;
    }
    result.data.appendSlice(gpa, src[0..kf]) catch { setError(.out_of_memory); };
    var i: usize = kf;
    while (i < src.len - kl) : (i += 1) {
        result.data.appendSlice(gpa, &[_]u8{mask_char}) catch break;
    }
    result.data.appendSlice(gpa, src[src.len - kl ..]) catch { setError(.out_of_memory); };
    return result;
}

// extract_words -> string/nlp.zig

// ─── Batch 22: expand_tabs, sentence_count, chop, scan_int, to_ordinal ───

// str_expand_tabs -> string/trim.zig

// str_sentence_count -> string/split.zig

pub export fn str_chop(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    if (src.len > 0) {
        result.data.appendSlice(gpa, src[0 .. src.len - 1]) catch { setError(.out_of_memory); };
    }
    return result;
}

pub export fn str_scan_int(handle: ?*StzString) callconv(.c) c_int {
    const s = handle orelse return 0;
    const src = s.slice();
    var val: c_int = 0;
    var neg = false;
    var started = false;
    for (src) |c| {
        if (!started and c == '-') {
            neg = true;
            started = true;
        } else if (c >= '0' and c <= '9') {
            val = val * 10 + @as(c_int, c - '0');
            started = true;
        } else if (started) break;
    }
    return if (neg) -val else val;
}

pub export fn str_to_ordinal(handle: ?*StzString) callconv(.c) ?*StzString {
    const s = handle orelse return null;
    const src = s.slice();
    const result = str_new() orelse return null;
    result.data.appendSlice(gpa, src) catch return result;
    // Parse the number to determine suffix
    const num = str_scan_int(s);
    const abs_num: u32 = if (num < 0) @intCast(-num) else @intCast(num);
    const last_two = abs_num % 100;
    const last_one = abs_num % 10;
    if (last_two >= 11 and last_two <= 13) {
        result.data.appendSlice(gpa, "th") catch { setError(.out_of_memory); };
    } else if (last_one == 1) {
        result.data.appendSlice(gpa, "st") catch { setError(.out_of_memory); };
    } else if (last_one == 2) {
        result.data.appendSlice(gpa, "nd") catch { setError(.out_of_memory); };
    } else if (last_one == 3) {
        result.data.appendSlice(gpa, "rd") catch { setError(.out_of_memory); };
    } else {
        result.data.appendSlice(gpa, "th") catch { setError(.out_of_memory); };
    }
    return result;
}

// str_cp_count -> string/extract.zig

// str_chars_split -> string/split.zig

// batch 17 ─── NLP: Jaro-Winkler, Metaphone, N-grams ───

// Jaro, Jaro-Winkler -> string/nlp.zig

// Metaphone -> string/nlp.zig

// char_ngrams, word_ngrams -> string/nlp.zig

// ─── Tests ───

test "sort_chars" {
    const s1 = str_from("dcba", 4);
    const asc = str_sort_chars_asc(s1);
    try std.testing.expect(mem.eql(u8, str_data(asc)[0..@intCast(str_size(asc))], "abcd"));
    str_free(asc);

    const desc = str_sort_chars_desc(s1);
    try std.testing.expect(mem.eql(u8, str_data(desc)[0..@intCast(str_size(desc))], "dcba"));
    str_free(desc);
    str_free(s1);
}

test "find_all_char" {
    const s1 = str_from("abcabc", 6);
    const fr = str_find_all_char(s1, 'a');
    try std.testing.expect(fr != null);
    try std.testing.expectEqual(@as(c_int, 2), stz_find_result_count(fr));
    try std.testing.expectEqual(@as(c_int, 1), stz_find_result_get(fr, 0));
    try std.testing.expectEqual(@as(c_int, 4), stz_find_result_get(fr, 1));
    stz_find_result_free(fr);
    str_free(s1);
}

test "hash" {
    const s1 = str_from("hello", 5);
    const h1 = str_hash(s1);
    const s2 = str_from("hello", 5);
    const h2 = str_hash(s2);
    try std.testing.expectEqual(h1, h2);
    str_free(s2);

    const s3 = str_from("world", 5);
    const h3 = str_hash(s3);
    try std.testing.expect(h1 != h3);
    str_free(s3);
    str_free(s1);
}

test "count_char" {
    const s1 = str_from("mississippi", 11);
    try std.testing.expectEqual(@as(c_int, 4), str_count_char(s1, 's'));
    try std.testing.expectEqual(@as(c_int, 2), str_count_char(s1, 'p'));
    try std.testing.expectEqual(@as(c_int, 4), str_count_char(s1, 'i'));
    str_free(s1);
}

test "replace_char" {
    const s1 = str_from("hello", 5);
    const r1 = str_replace_char(s1, 'l', 'r');
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "herro"));
    str_free(r1);
    str_free(s1);
}

test "copy" {
    const s1 = str_from("hello", 5);
    const s2 = str_copy(s1);
    try std.testing.expect(mem.eql(u8, str_data(s2)[0..@intCast(str_size(s2))], "hello"));
    str_free(s2);
    str_free(s1);
}

test "compare" {
    const s1 = str_from("abc", 3);
    const s2 = str_from("abc", 3);
    const s3 = str_from("abd", 3);
    const s4 = str_from("ab", 2);
    try std.testing.expectEqual(@as(c_int, 0), str_compare(s1, s2));
    try std.testing.expectEqual(@as(c_int, -1), str_compare(s1, s3));
    try std.testing.expectEqual(@as(c_int, 1), str_compare(s3, s1));
    try std.testing.expectEqual(@as(c_int, 1), str_compare(s1, s4));
    try std.testing.expectEqual(@as(c_int, -1), str_compare(s4, s1));
    str_free(s4);
    str_free(s3);
    str_free(s2);
    str_free(s1);
}

test "remove_first_occurrence" {
    const s1 = str_from("hello world hello", 17);
    const r1 = str_remove_first_occurrence(s1, "hello", 5);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], " world hello"));
    str_free(r1);
    str_free(s1);
}

test "remove_last_occurrence" {
    const s1 = str_from("hello world hello", 17);
    const r1 = str_remove_last_occurrence(s1, "hello", 5);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "hello world "));
    str_free(r1);
    str_free(s1);
}

test "remove_nth_occurrence" {
    const s1 = str_from("abcabcabc", 9);
    const r0 = str_remove_nth_occurrence(s1, "abc", 3, 0);
    try std.testing.expect(mem.eql(u8, str_data(r0)[0..@intCast(str_size(r0))], "abcabc"));
    str_free(r0);
    const r1 = str_remove_nth_occurrence(s1, "abc", 3, 1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "abcabc"));
    str_free(r1);
    const r2 = str_remove_nth_occurrence(s1, "abc", 3, 2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "abcabc"));
    str_free(r2);
    str_free(s1);
}

test "repeat_char" {
    const r1 = str_repeat_char('*', 5);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "*****"));
    str_free(r1);

    const r2 = str_repeat_char('-', 0);
    try std.testing.expectEqual(@as(c_int, 0), str_size(r2));
    str_free(r2);
}

test "insert_before_each" {
    const s1 = str_from("abcabc", 6);
    const r1 = str_insert_before_each(s1, "abc", 3, "[", 1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "[abc[abc"));
    str_free(r1);
    str_free(s1);
}

test "insert_after_each" {
    const s1 = str_from("abcabc", 6);
    const r1 = str_insert_after_each(s1, "abc", 3, "]", 1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "abc]abc]"));
    str_free(r1);
    str_free(s1);
}

test "truncate" {
    const s1 = str_from("Hello World", 11);
    const r1 = str_truncate(s1, 5, "...", 3);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "Hello..."));
    str_free(r1);

    // String shorter than max - no truncation
    const r2 = str_truncate(s1, 20, "...", 3);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "Hello World"));
    str_free(r2);
    str_free(s1);
}

test "wrap_at" {
    const s1 = str_from("hello world foo bar", 19);
    const r1 = str_wrap_at(s1, 10);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "hello\nworld foo\nbar"));
    str_free(r1);
    str_free(s1);
}

test "is_chars_sorted" {
    const s1 = str_from("abcd", 4);
    try std.testing.expectEqual(@as(c_int, 1), str_is_chars_sorted_asc(s1));
    try std.testing.expectEqual(@as(c_int, 0), str_is_chars_sorted_desc(s1));
    str_free(s1);

    const s2 = str_from("dcba", 4);
    try std.testing.expectEqual(@as(c_int, 0), str_is_chars_sorted_asc(s2));
    try std.testing.expectEqual(@as(c_int, 1), str_is_chars_sorted_desc(s2));
    str_free(s2);

    const s3 = str_from("a", 1);
    try std.testing.expectEqual(@as(c_int, 1), str_is_chars_sorted_asc(s3));
    try std.testing.expectEqual(@as(c_int, 1), str_is_chars_sorted_desc(s3));
    str_free(s3);
}

test "remove_prefix_suffix" {
    const s1 = str_from("Hello World", 11);
    const r1 = str_remove_prefix(s1, "Hello ", 6);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "World"));
    str_free(r1);

    const r2 = str_remove_suffix(s1, " World", 6);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "Hello"));
    str_free(r2);

    // No match - returns copy
    const r3 = str_remove_prefix(s1, "xyz", 3);
    try std.testing.expect(mem.eql(u8, str_data(r3)[0..@intCast(str_size(r3))], "Hello World"));
    str_free(r3);
    str_free(s1);
}

test "ensure_prefix_suffix" {
    const s1 = str_from("world", 5);
    const r1 = str_ensure_prefix(s1, "hello ", 6);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "hello world"));
    str_free(r1);
    str_free(s1);

    const s2 = str_from("hello world", 11);
    const r2 = str_ensure_prefix(s2, "hello", 5);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "hello world"));
    str_free(r2);

    const r3 = str_ensure_suffix(s2, ".txt", 4);
    try std.testing.expect(mem.eql(u8, str_data(r3)[0..@intCast(str_size(r3))], "hello world.txt"));
    str_free(r3);
    str_free(s2);
}

test "squeeze_char" {
    const s1 = str_from("heeellooo", 9);
    const r1 = str_squeeze_char(s1, 'e');
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "hellooo"));
    str_free(r1);

    const r2 = str_squeeze_char(s1, 'o');
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "heeello"));
    str_free(r2);
    str_free(s1);
}

test "capitalize_decapitalize_first" {
    const s1 = str_from("hello world", 11);
    const r1 = str_capitalize_first(s1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "Hello world"));
    str_free(r1);
    str_free(s1);

    const s2 = str_from("Hello", 5);
    const r2 = str_decapitalize_first(s2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "hello"));
    str_free(r2);
    str_free(s2);
}

test "zfill" {
    const s1 = str_from("42", 2);
    const r1 = str_zfill(s1, 5);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "00042"));
    str_free(r1);

    const r2 = str_zfill(s1, 2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "42"));
    str_free(r2);
    str_free(s1);
}

test "tab_expand" {
    const s1 = str_from("a\tb\tc", 5);
    const r1 = str_tab_expand(s1, 4);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "a    b    c"));
    str_free(r1);
    str_free(s1);
}

test "count_overlapping" {
    const s1 = str_from("aaaa", 4);
    try std.testing.expectEqual(@as(c_int, 3), str_count_overlapping(s1, "aa", 2));
    str_free(s1);

    const s2 = str_from("abcabc", 6);
    try std.testing.expectEqual(@as(c_int, 2), str_count_overlapping(s2, "abc", 3));
    str_free(s2);
}

test "replace_at" {
    const s1 = str_from("Hello World", 11);
    const r1 = str_replace_at(s1, 6, 1, "-", 1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "Hello-World"));
    str_free(r1);
    str_free(s1);
}

test "contains_any_of" {
    const s1 = str_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_contains_any_of(s1, "aeiou", 5));
    try std.testing.expectEqual(@as(c_int, 0), str_contains_any_of(s1, "xyz", 3));
    str_free(s1);
}

test "contains_all_of" {
    const s1 = str_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_contains_all_of(s1, "helo", 4));
    try std.testing.expectEqual(@as(c_int, 0), str_contains_all_of(s1, "heloz", 5));
    str_free(s1);
}

test "foldcase" {
    const s1 = str_from("Hello WORLD", 11);
    const folded = str_foldcase(s1);
    try std.testing.expect(mem.eql(u8, str_data(folded)[0..@intCast(str_size(folded))], "hello world"));
    str_free(folded);
    str_free(s1);
}

test "center_pad" {
    const s1 = str_from("hi", 2);
    const padded = str_center_pad(s1, 6, "-", 1);
    try std.testing.expect(mem.eql(u8, str_data(padded)[0..@intCast(str_size(padded))], "--hi--"));
    str_free(padded);

    const padded_odd = str_center_pad(s1, 7, "*", 1);
    try std.testing.expect(mem.eql(u8, str_data(padded_odd)[0..@intCast(str_size(padded_odd))], "**hi***"));
    str_free(padded_odd);
    str_free(s1);
}

test "only_letters" {
    const s1 = str_from("h3ll0 w0rld!", 12);
    const letters = str_only_letters(s1);
    try std.testing.expect(mem.eql(u8, str_data(letters)[0..@intCast(str_size(letters))], "hllwrld"));
    str_free(letters);
    str_free(s1);
}

test "only_digits" {
    const s1 = str_from("a1b2c3", 6);
    const digits = str_only_digits(s1);
    try std.testing.expect(mem.eql(u8, str_data(digits)[0..@intCast(str_size(digits))], "123"));
    str_free(digits);
    str_free(s1);
}

test "remove_whitespace" {
    const s1 = str_from("h e l l o", 9);
    const nows = str_remove_whitespace(s1);
    try std.testing.expect(mem.eql(u8, str_data(nows)[0..@intCast(str_size(nows))], "hello"));
    str_free(nows);
    str_free(s1);
}

test "is_palindrome" {
    const s1 = str_from("abcba", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_is_palindrome(s1));
    str_free(s1);

    const s2 = str_from("abcd", 4);
    try std.testing.expectEqual(@as(c_int, 0), str_is_palindrome(s2));
    str_free(s2);

    const s3 = str_from("a", 1);
    try std.testing.expectEqual(@as(c_int, 1), str_is_palindrome(s3));
    str_free(s3);
}

test "count_words" {
    const s1 = str_from("hello world foo", 15);
    try std.testing.expectEqual(@as(c_int, 3), str_count_words(s1));
    str_free(s1);

    const s2 = str_from("  hello  ", 9);
    try std.testing.expectEqual(@as(c_int, 1), str_count_words(s2));
    str_free(s2);

    const s3 = str_from("", 0);
    try std.testing.expectEqual(@as(c_int, 0), str_count_words(s3));
    str_free(s3);
}

test "nth_word" {
    const s1 = str_from("hello world foo", 15);
    const w0 = str_nth_word(s1, 0);
    try std.testing.expect(mem.eql(u8, str_data(w0)[0..@intCast(str_size(w0))], "hello"));
    str_free(w0);

    const w1 = str_nth_word(s1, 1);
    try std.testing.expect(mem.eql(u8, str_data(w1)[0..@intCast(str_size(w1))], "world"));
    str_free(w1);

    const w2 = str_nth_word(s1, 2);
    try std.testing.expect(mem.eql(u8, str_data(w2)[0..@intCast(str_size(w2))], "foo"));
    str_free(w2);
    str_free(s1);
}

test "chars_between" {
    const s1 = str_from("abcdef", 6);
    const between = str_chars_between(s1, 2, 5);
    try std.testing.expect(mem.eql(u8, str_data(between)[0..@intCast(str_size(between))], "cd"));
    str_free(between);
    str_free(s1);
}

test "is_alphanumeric" {
    const s1 = str_from("hello123", 8);
    try std.testing.expectEqual(@as(c_int, 1), str_is_alphanumeric(s1));
    str_free(s1);

    const s2 = str_from("hello 123", 9);
    try std.testing.expectEqual(@as(c_int, 0), str_is_alphanumeric(s2));
    str_free(s2);

    const s3 = str_from("", 0);
    try std.testing.expectEqual(@as(c_int, 0), str_is_alphanumeric(s3));
    str_free(s3);
}

test "ljust_rjust" {
    const s1 = str_from("hi", 2);
    const lj = str_ljust(s1, 5, ".", 1);
    try std.testing.expect(mem.eql(u8, str_data(lj)[0..@intCast(str_size(lj))], "hi..."));
    str_free(lj);

    const rj = str_rjust(s1, 5, ".", 1);
    try std.testing.expect(mem.eql(u8, str_data(rj)[0..@intCast(str_size(rj))], "...hi"));
    str_free(rj);
    str_free(s1);
}

test "common_prefix" {
    const s1 = str_from("hello world", 11);
    const s2 = str_from("hello there", 11);
    const cp = str_common_prefix(s1, s2);
    try std.testing.expect(mem.eql(u8, str_data(cp)[0..@intCast(str_size(cp))], "hello "));
    str_free(cp);
    str_free(s2);
    str_free(s1);
}

test "indent_dedent" {
    const s1 = str_from("line1\nline2", 11);
    const indented = str_indent(s1, 2);
    try std.testing.expect(mem.eql(u8, str_data(indented)[0..@intCast(str_size(indented))], "  line1\n  line2"));
    str_free(indented);
    str_free(s1);

    const s2 = str_from("    hello\n    world", 19);
    const dedented = str_dedent(s2);
    try std.testing.expect(mem.eql(u8, str_data(dedented)[0..@intCast(str_size(dedented))], "hello\nworld"));
    str_free(dedented);
    str_free(s2);
}

test "camel_snake_kebab" {
    const s1 = str_from("hello world", 11);
    const camel = str_to_camel_case(s1);
    try std.testing.expect(mem.eql(u8, str_data(camel)[0..@intCast(str_size(camel))], "helloWorld"));
    str_free(camel);
    str_free(s1);

    const s2 = str_from("helloWorld", 10);
    const snake = str_to_snake_case(s2);
    try std.testing.expect(mem.eql(u8, str_data(snake)[0..@intCast(str_size(snake))], "hello_world"));
    str_free(snake);

    const kebab = str_to_kebab_case(s2);
    try std.testing.expect(mem.eql(u8, str_data(kebab)[0..@intCast(str_size(kebab))], "hello-world"));
    str_free(kebab);
    str_free(s2);
}

test "partition" {
    const s1 = str_from("hello:world:foo", 15);
    const before = str_partition(s1, ":", 1);
    try std.testing.expect(mem.eql(u8, str_data(before)[0..@intCast(str_size(before))], "hello"));
    str_free(before);

    const after = str_partition_after(s1, ":", 1);
    try std.testing.expect(mem.eql(u8, str_data(after)[0..@intCast(str_size(after))], "world:foo"));
    str_free(after);

    // Not found
    const before2 = str_partition(s1, "xyz", 3);
    try std.testing.expect(mem.eql(u8, str_data(before2)[0..@intCast(str_size(before2))], "hello:world:foo"));
    str_free(before2);

    const after2 = str_partition_after(s1, "xyz", 3);
    try std.testing.expectEqual(@as(c_int, 0), str_size(after2));
    str_free(after2);
    str_free(s1);
}

test "rpartition" {
    const s1 = str_from("hello:world:foo", 15);
    const before = str_rpartition(s1, ":", 1);
    try std.testing.expect(mem.eql(u8, str_data(before)[0..@intCast(str_size(before))], "hello:world"));
    str_free(before);

    const after = str_rpartition_after(s1, ":", 1);
    try std.testing.expect(mem.eql(u8, str_data(after)[0..@intCast(str_size(after))], "foo"));
    str_free(after);
    str_free(s1);
}

test "squeeze" {
    const s1 = str_from("heeellooo", 9);
    const r1 = str_squeeze(s1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "helo"));
    str_free(r1);
    str_free(s1);

    const s2 = str_from("aabbcc", 6);
    const r2 = str_squeeze(s2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "abc"));
    str_free(r2);
    str_free(s2);
}

test "is_digit" {
    const s1 = str_from("12345", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_is_digit(s1));
    str_free(s1);

    const s2 = str_from("123a5", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_is_digit(s2));
    str_free(s2);

    const s3 = str_from("", 0);
    try std.testing.expectEqual(@as(c_int, 0), str_is_digit(s3));
    str_free(s3);
}

test "interleave" {
    const s1 = str_from("abc", 3);
    const r1 = str_interleave(s1, ",", 1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "a,b,c"));
    str_free(r1);

    const r2 = str_interleave(s1, " - ", 3);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "a - b - c"));
    str_free(r2);
    str_free(s1);
}

test "strip_chars" {
    const s1 = str_from("hello world!", 12);
    const r1 = str_strip_chars(s1, "lo", 2);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "he wrd!"));
    str_free(r1);
    str_free(s1);

    // Strip vowels
    const s2 = str_from("programming", 11);
    const r2 = str_strip_chars(s2, "aeiou", 5);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "prgrmmng"));
    str_free(r2);
    str_free(s2);
}

test "keep_chars" {
    const s1 = str_from("hello world!", 12);
    const r1 = str_keep_chars(s1, "lo", 2);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "llool"));
    str_free(r1);
    str_free(s1);
}

test "replace2" {
    const s1 = str_from("hello world", 11);
    const r1 = str_replace2(s1, "hello", 5, "hi", 2, "world", 5, "earth", 5);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "hi earth"));
    str_free(r1);
    str_free(s1);
}

test "rotate" {
    const s1 = str_from("abcde", 5);
    const r1 = str_rotate(s1, 2);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "cdeab"));
    str_free(r1);

    // Rotate right (negative)
    const r2 = str_rotate(s1, -1);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "eabcd"));
    str_free(r2);

    // Rotate by length = no change
    const r3 = str_rotate(s1, 5);
    try std.testing.expect(mem.eql(u8, str_data(r3)[0..@intCast(str_size(r3))], "abcde"));
    str_free(r3);
    str_free(s1);
}

test "repeat_to_length" {
    const s1 = str_from("abc", 3);
    const r1 = str_repeat_to_length(s1, 7);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "abcabca"));
    str_free(r1);

    const r2 = str_repeat_to_length(s1, 3);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "abc"));
    str_free(r2);

    const r3 = str_repeat_to_length(s1, 1);
    try std.testing.expect(mem.eql(u8, str_data(r3)[0..@intCast(str_size(r3))], "a"));
    str_free(r3);
    str_free(s1);
}

test "remove_between" {
    const s1 = str_from("hello [world] end", 17);
    const r1 = str_remove_between(s1, "[", 1, "]", 1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "hello  end"));
    str_free(r1);
    str_free(s1);

    // HTML tags
    const s2 = str_from("before<tag>inside</tag>after", 28);
    const r2 = str_remove_between(s2, "<tag>", 5, "</tag>", 6);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "beforeafter"));
    str_free(r2);
    str_free(s2);
}

test "is_blank" {
    const s1 = str_from("   ", 3);
    try std.testing.expectEqual(@as(c_int, 1), str_is_blank(s1));
    str_free(s1);

    const s2 = str_from("", 0);
    try std.testing.expectEqual(@as(c_int, 1), str_is_blank(s2));
    str_free(s2);

    const s3 = str_from(" a ", 3);
    try std.testing.expectEqual(@as(c_int, 0), str_is_blank(s3));
    str_free(s3);
}

test "to_pascal_case" {
    const s1 = str_from("hello_world", 11);
    const r1 = str_to_pascal_case(s1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "HelloWorld"));
    str_free(r1);
    str_free(s1);

    const s2 = str_from("my-kebab-case", 13);
    const r2 = str_to_pascal_case(s2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "MyKebabCase"));
    str_free(r2);
    str_free(s2);

    const s3 = str_from("already PascalCase", 18);
    const r3 = str_to_pascal_case(s3);
    try std.testing.expect(mem.eql(u8, str_data(r3)[0..@intCast(str_size(r3))], "AlreadyPascalCase"));
    str_free(r3);
    str_free(s3);
}

test "is_identifier" {
    const s1 = str_from("hello_world", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_is_identifier(s1));
    str_free(s1);

    const s2 = str_from("_private", 8);
    try std.testing.expectEqual(@as(c_int, 1), str_is_identifier(s2));
    str_free(s2);

    const s3 = str_from("3invalid", 8);
    try std.testing.expectEqual(@as(c_int, 0), str_is_identifier(s3));
    str_free(s3);

    const s4 = str_from("has space", 9);
    try std.testing.expectEqual(@as(c_int, 0), str_is_identifier(s4));
    str_free(s4);

    const s5 = str_from("CamelCase123", 12);
    try std.testing.expectEqual(@as(c_int, 1), str_is_identifier(s5));
    str_free(s5);
}

test "replace_between" {
    const s1 = str_from("hello [world] end", 17);
    const r1 = str_replace_between(s1, "[", 1, "]", 1, "REPLACED", 8);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "hello REPLACED end"));
    str_free(r1);
    str_free(s1);

    // Replace with empty
    const s2 = str_from("a<b>c", 5);
    const r2 = str_replace_between(s2, "<", 1, ">", 1, "", 0);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "ac"));
    str_free(r2);
    str_free(s2);
}

test "contains_only" {
    const s1 = str_from("aabbcc", 6);
    try std.testing.expectEqual(@as(c_int, 1), str_contains_only(s1, "abc", 3));
    try std.testing.expectEqual(@as(c_int, 0), str_contains_only(s1, "ab", 2));
    str_free(s1);

    const s2 = str_from("12345", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_contains_only(s2, "0123456789", 10));
    str_free(s2);
}

test "capitalize_words" {
    const s1 = str_from("hello world", 11);
    const r1 = str_capitalize_words(s1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "Hello World"));
    str_free(r1);
    str_free(s1);

    const s2 = str_from("already OK here", 15);
    const r2 = str_capitalize_words(s2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "Already OK Here"));
    str_free(r2);
    str_free(s2);
}

test "swap_chars" {
    const s1 = str_from("abcde", 5);
    const r1 = str_swap_chars(s1, 1, 5);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "ebcda"));
    str_free(r1);

    const r2 = str_swap_chars(s1, 2, 4);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "adcbe"));
    str_free(r2);
    str_free(s1);
}

test "encode_hex" {
    const s1 = str_from("Hi", 2);
    const r1 = str_encode_hex(s1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "4869"));
    str_free(r1);
    str_free(s1);
}

test "decode_hex" {
    const s1 = str_from("4869", 4);
    const r1 = str_decode_hex(s1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "Hi"));
    str_free(r1);
    str_free(s1);
}

test "reverse_words" {
    const s1 = str_from("hello world foo", 15);
    const r1 = str_reverse_words(s1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "foo world hello"));
    str_free(r1);
    str_free(s1);

    const s2 = str_from("single", 6);
    const r2 = str_reverse_words(s2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "single"));
    str_free(r2);
    str_free(s2);
}

test "collapse_spaces" {
    const s1 = str_from("  hello   world  ", 17);
    const r1 = str_collapse_spaces(s1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "hello world"));
    str_free(r1);
    str_free(s1);

    const s2 = str_from("no extra spaces", 15);
    const r2 = str_collapse_spaces(s2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "no extra spaces"));
    str_free(r2);
    str_free(s2);
}

test "is_anagram" {
    const s1 = str_from("listen", 6);
    const s2 = str_from("silent", 6);
    try std.testing.expectEqual(@as(c_int, 1), str_is_anagram(s1, s2));
    str_free(s2);

    const s3 = str_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_is_anagram(s1, s3));
    str_free(s3);
    str_free(s1);
}

test "mask" {
    const s1 = str_from("hello@mail.com", 14);
    const r1 = str_mask(s1, "*", 1, 2);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "he**********om"));
    str_free(r1);
    str_free(s1);

    const s2 = str_from("ab", 2);
    const r2 = str_mask(s2, "*", 1, 2);
    // Too short to mask (2 chars, keep 2+2=4), returns as-is
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "ab"));
    str_free(r2);
    str_free(s2);
}

test "count_runs" {
    const s1 = str_from("aabbbcc", 7);
    try std.testing.expectEqual(@as(c_int, 3), str_count_runs(s1));
    str_free(s1);

    const s2 = str_from("abcde", 5);
    try std.testing.expectEqual(@as(c_int, 5), str_count_runs(s2));
    str_free(s2);

    const s3 = str_from("aaaa", 4);
    try std.testing.expectEqual(@as(c_int, 1), str_count_runs(s3));
    str_free(s3);
}

test "hamming_distance" {
    const s1 = str_from("karolin", 7);
    const s2 = str_from("kathrin", 7);
    try std.testing.expectEqual(@as(c_int, 3), str_hamming_distance(s1, s2));
    str_free(s2);
    str_free(s1);

    const s3 = str_from("abc", 3);
    const s4 = str_from("abcd", 4);
    try std.testing.expectEqual(@as(c_int, -1), str_hamming_distance(s3, s4));
    str_free(s4);
    str_free(s3);
}

test "remove_vowels" {
    const h = str_from("Hello World", 11);
    const r = str_remove_vowels(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "Hll Wrld"));
    str_free(r);
    str_free(h);

    const h2 = str_from("aeiou", 5);
    const r2 = str_remove_vowels(h2);
    try std.testing.expectEqual(@as(c_int, 0), str_size(r2));
    str_free(r2);
    str_free(h2);
}

test "only_vowels" {
    const h = str_from("Hello World", 11);
    const r = str_only_vowels(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "eoo"));
    str_free(r);
    str_free(h);

    const h2 = str_from("xyz", 3);
    const r2 = str_only_vowels(h2);
    try std.testing.expectEqual(@as(c_int, 0), str_size(r2));
    str_free(r2);
    str_free(h2);
}

test "is_pangram" {
    const h = str_from("The quick brown fox jumps over the lazy dog", 43);
    try std.testing.expectEqual(@as(c_int, 1), str_is_pangram(h));
    str_free(h);

    const h2 = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 0), str_is_pangram(h2));
    str_free(h2);
}

test "ngram" {
    const h = str_from("hello", 5);
    const r = str_ngram(h, 2, 0);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "he"));
    str_free(r);

    const r2 = str_ngram(h, 2, 3);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "lo"));
    str_free(r2);

    const r3 = str_ngram(h, 2, 4);
    try std.testing.expectEqual(@as(StzStringHandle, null), r3);
    str_free(h);
}

test "ngram_count" {
    const h = str_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 4), str_ngram_count(h, 2));
    try std.testing.expectEqual(@as(c_int, 3), str_ngram_count(h, 3));
    try std.testing.expectEqual(@as(c_int, 1), str_ngram_count(h, 5));
    try std.testing.expectEqual(@as(c_int, 0), str_ngram_count(h, 6));
    str_free(h);
}

test "count_consonants" {
    const h = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 7), str_count_consonants(h));
    str_free(h);

    const h2 = str_from("aeiou", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_count_consonants(h2));
    str_free(h2);
}

test "to_sentence_case" {
    const h = str_from("hELLO WORLD", 11);
    const r = str_to_sentence_case(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "Hello world"));
    str_free(r);
    str_free(h);

    const h2 = str_from("already lowercase", 17);
    const r2 = str_to_sentence_case(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "Already lowercase"));
    str_free(r2);
    str_free(h2);
}

test "is_balanced" {
    const h1 = str_from("(hello [world])", 15);
    try std.testing.expectEqual(@as(c_int, 1), str_is_balanced(h1));
    str_free(h1);

    const h2 = str_from("(hello [world)", 14);
    try std.testing.expectEqual(@as(c_int, 0), str_is_balanced(h2));
    str_free(h2);

    const h3 = str_from("{[()]}", 6);
    try std.testing.expectEqual(@as(c_int, 1), str_is_balanced(h3));
    str_free(h3);
}

test "slug" {
    const h = str_from("Hello World! This is a Test", 27);
    const r = str_slug(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "hello-world-this-is-a-test"));
    str_free(r);
    str_free(h);

    const h2 = str_from("  Multiple   Spaces  ", 21);
    const r2 = str_slug(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "multiple-spaces"));
    str_free(r2);
    str_free(h2);
}

test "chunk" {
    const h = str_from("abcdefgh", 8);
    const r0 = str_chunk(h, 3, 0);
    try std.testing.expect(mem.eql(u8, str_data(r0)[0..@intCast(str_size(r0))], "abc"));
    str_free(r0);

    const r1 = str_chunk(h, 3, 1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "def"));
    str_free(r1);

    const r2 = str_chunk(h, 3, 2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "gh"));
    str_free(r2);

    const r3 = str_chunk(h, 3, 3);
    try std.testing.expectEqual(@as(StzStringHandle, null), r3);
    str_free(h);
}

test "count_vowels" {
    const h = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 3), str_count_vowels(h));
    str_free(h);

    const h2 = str_from("bcdfg", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_count_vowels(h2));
    str_free(h2);
}

test "longest_run" {
    const h = str_from("aabbbcccc", 9);
    try std.testing.expectEqual(@as(c_int, 4), str_longest_run(h));
    str_free(h);

    const h2 = str_from("abc", 3);
    try std.testing.expectEqual(@as(c_int, 1), str_longest_run(h2));
    str_free(h2);
}

test "trim_chars" {
    const h = str_from("***hello***", 11);
    const r = str_trim_chars(h, "*", 1);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "hello"));
    str_free(r);
    str_free(h);

    const h2 = str_from("--=hello=--", 11);
    const r2 = str_trim_chars(h2, "-=", 2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "hello"));
    str_free(r2);
    str_free(h2);
}

test "is_email_like" {
    const h1 = str_from("user@example.com", 16);
    try std.testing.expectEqual(@as(c_int, 1), str_is_email_like(h1));
    str_free(h1);

    const h2 = str_from("no-at-sign.com", 14);
    try std.testing.expectEqual(@as(c_int, 0), str_is_email_like(h2));
    str_free(h2);

    const h3 = str_from("@nodomain", 9);
    try std.testing.expectEqual(@as(c_int, 0), str_is_email_like(h3));
    str_free(h3);
}

test "camel_to_words" {
    const h = str_from("camelCaseString", 15);
    const r = str_camel_to_words(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "camel Case String"));
    str_free(r);
    str_free(h);

    const h2 = str_from("HTMLParser", 10);
    const r2 = str_camel_to_words(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "HTML Parser"));
    str_free(r2);
    str_free(h2);
}

test "initials" {
    const h = str_from("Hello World", 11);
    const r = str_initials(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "HW"));
    str_free(r);
    str_free(h);

    const h2 = str_from("united states of america", 24);
    const r2 = str_initials(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "usoa"));
    str_free(r2);
    str_free(h2);
}

test "remove_duplicate_words" {
    const h = str_from("the the cat sat on the mat", 26);
    const r = str_remove_duplicate_words(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "the cat sat on mat"));
    str_free(r);
    str_free(h);

    const h2 = str_from("abc def abc", 11);
    const r2 = str_remove_duplicate_words(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "abc def"));
    str_free(r2);
    str_free(h2);
}

test "is_url_like" {
    const h1 = str_from("https://example.com", 19);
    try std.testing.expectEqual(@as(c_int, 1), str_is_url_like(h1));
    str_free(h1);

    const h2 = str_from("http://example.com", 18);
    try std.testing.expectEqual(@as(c_int, 1), str_is_url_like(h2));
    str_free(h2);

    const h3 = str_from("ftp://files.com", 15);
    try std.testing.expectEqual(@as(c_int, 0), str_is_url_like(h3));
    str_free(h3);
}

test "escape_html" {
    const h = str_from("<b>&hi</b>", 10);
    const r = str_escape_html(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "&lt;b&gt;&amp;hi&lt;/b&gt;"));
    str_free(r);
    str_free(h);
}

test "unescape_html" {
    const h = str_from("&lt;b&gt;hello&lt;/b&gt;", 24);
    const r = str_unescape_html(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "<b>hello</b>"));
    str_free(r);
    str_free(h);
}

test "count_sentences" {
    const h = str_from("Hello. How are you? Fine!", 25);
    try std.testing.expectEqual(@as(c_int, 3), str_count_sentences(h));
    str_free(h);

    const h2 = str_from("No sentence end", 15);
    try std.testing.expectEqual(@as(c_int, 0), str_count_sentences(h2));
    str_free(h2);
}

test "title_smart" {
    const h = str_from("the lord of the rings", 21);
    const r = str_title_smart(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "The Lord of the Rings"));
    str_free(r);
    str_free(h);

    const h2 = str_from("a tale of two cities", 20);
    const r2 = str_title_smart(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "A Tale of Two Cities"));
    str_free(r2);
    str_free(h2);
}

test "remove_punctuation" {
    const h = str_from("Hello, World! How's it?", 23);
    const r = str_remove_punctuation(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "Hello World Hows it"));
    str_free(r);
    str_free(h);
}

test "is_float" {
    const h1 = str_from("3.14", 4);
    try std.testing.expectEqual(@as(c_int, 1), str_is_float(h1));
    str_free(h1);

    const h2 = str_from("-0.5", 4);
    try std.testing.expectEqual(@as(c_int, 1), str_is_float(h2));
    str_free(h2);

    const h3 = str_from("42", 2);
    try std.testing.expectEqual(@as(c_int, 0), str_is_float(h3));
    str_free(h3);

    const h4 = str_from("1.2.3", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_is_float(h4));
    str_free(h4);
}

test "digit_sum" {
    const h = str_from("a1b2c3", 6);
    try std.testing.expectEqual(@as(c_int, 6), str_digit_sum(h));
    str_free(h);

    const h2 = str_from("999", 3);
    try std.testing.expectEqual(@as(c_int, 27), str_digit_sum(h2));
    str_free(h2);

    const h3 = str_from("abc", 3);
    try std.testing.expectEqual(@as(c_int, 0), str_digit_sum(h3));
    str_free(h3);
}

test "to_alternating_case" {
    const h = str_from("hello world", 11);
    const r = str_to_alternating_case(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "hElLo WoRlD"));
    str_free(r);
    str_free(h);
}

test "count_upper_lower" {
    const h = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 2), str_count_upper(h));
    try std.testing.expectEqual(@as(c_int, 8), str_count_lower(h));
    str_free(h);
}

test "is_camel_case" {
    const h1 = str_from("camelCase", 9);
    try std.testing.expectEqual(@as(c_int, 1), str_is_camel_case(h1));
    str_free(h1);

    const h2 = str_from("PascalCase", 10);
    try std.testing.expectEqual(@as(c_int, 0), str_is_camel_case(h2));
    str_free(h2);

    const h3 = str_from("lowercase", 9);
    try std.testing.expectEqual(@as(c_int, 0), str_is_camel_case(h3));
    str_free(h3);

    const h4 = str_from("has space", 9);
    try std.testing.expectEqual(@as(c_int, 0), str_is_camel_case(h4));
    str_free(h4);
}

test "common_chars" {
    const h1 = str_from("hello", 5);
    const h2 = str_from("world", 5);
    const r = str_common_chars(h1, h2);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "lo"));
    str_free(r);
    str_free(h2);
    str_free(h1);
}

test "count_lines" {
    const h1 = str_from("hello\nworld\nfoo", 15);
    try std.testing.expectEqual(@as(c_int, 3), str_count_lines(h1));
    str_free(h1);

    const h2 = str_from("single line", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_count_lines(h2));
    str_free(h2);

    const h3 = str_from("", 0);
    try std.testing.expectEqual(@as(c_int, 0), str_count_lines(h3));
    str_free(h3);
}

test "is_snake_case" {
    const h1 = str_from("hello_world", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_is_snake_case(h1));
    str_free(h1);

    const h2 = str_from("my_var_name", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_is_snake_case(h2));
    str_free(h2);

    const h3 = str_from("camelCase", 9);
    try std.testing.expectEqual(@as(c_int, 0), str_is_snake_case(h3));
    str_free(h3);

    const h4 = str_from("hello__world", 12);
    try std.testing.expectEqual(@as(c_int, 0), str_is_snake_case(h4));
    str_free(h4);

    const h5 = str_from("single", 6);
    try std.testing.expectEqual(@as(c_int, 0), str_is_snake_case(h5));
    str_free(h5);
}

test "is_kebab_case" {
    const h1 = str_from("hello-world", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_is_kebab_case(h1));
    str_free(h1);

    const h2 = str_from("my-var-name", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_is_kebab_case(h2));
    str_free(h2);

    const h3 = str_from("camelCase", 9);
    try std.testing.expectEqual(@as(c_int, 0), str_is_kebab_case(h3));
    str_free(h3);

    const h4 = str_from("hello--world", 12);
    try std.testing.expectEqual(@as(c_int, 0), str_is_kebab_case(h4));
    str_free(h4);
}

test "count_unique_chars" {
    const h1 = str_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 4), str_count_unique_chars(h1));
    str_free(h1);

    const h2 = str_from("aaa", 3);
    try std.testing.expectEqual(@as(c_int, 1), str_count_unique_chars(h2));
    str_free(h2);

    const h3 = str_from("abcdef", 6);
    try std.testing.expectEqual(@as(c_int, 6), str_count_unique_chars(h3));
    str_free(h3);
}

test "caesar" {
    const h1 = str_from("abc", 3);
    const r1 = str_caesar(h1, 1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "bcd"));
    str_free(r1);
    str_free(h1);

    const h2 = str_from("xyz", 3);
    const r2 = str_caesar(h2, 3);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "abc"));
    str_free(r2);
    str_free(h2);

    const h3 = str_from("Hello, World!", 13);
    const r3 = str_caesar(h3, 13);
    try std.testing.expect(mem.eql(u8, str_data(r3)[0..@intCast(str_size(r3))], "Uryyb, Jbeyq!"));
    str_free(r3);
    str_free(h3);
}

test "mirror" {
    const h = str_from("abc", 3);
    const r = str_mirror(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "abccba"));
    str_free(r);
    str_free(h);

    const h2 = str_from("a", 1);
    const r2 = str_mirror(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "aa"));
    str_free(r2);
    str_free(h2);
}

test "repeat_each_char" {
    const h = str_from("abc", 3);
    const r = str_repeat_each_char(h, 2);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "aabbcc"));
    str_free(r);
    str_free(h);

    const h2 = str_from("hi", 2);
    const r2 = str_repeat_each_char(h2, 3);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "hhhiii"));
    str_free(r2);
    str_free(h2);
}

test "starts_with_any" {
    const h = str_from("https://example.com", 19);
    try std.testing.expectEqual(@as(c_int, 1), str_starts_with_any(h, "http|ftp|ssh", 12));
    try std.testing.expectEqual(@as(c_int, 0), str_starts_with_any(h, "ftp|ssh", 7));
    str_free(h);
}

test "ends_with_any" {
    const h = str_from("file.zig", 8);
    try std.testing.expectEqual(@as(c_int, 1), str_ends_with_any(h, ".txt|.zig|.rs", 13));
    try std.testing.expectEqual(@as(c_int, 0), str_ends_with_any(h, ".txt|.rs|.go", 12));
    str_free(h);
}

test "to_binary" {
    const h = str_from("Hi", 2);
    const r = str_to_binary(h);
    // H = 72 = 01001000, i = 105 = 01101001
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "01001000 01101001"));
    str_free(r);
    str_free(h);
}

test "sort_words" {
    const h = str_from("banana apple cherry", 19);
    const r = str_sort_words(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "apple banana cherry"));
    str_free(r);
    str_free(h);

    const h2 = str_from("zig is fun", 10);
    const r2 = str_sort_words(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "fun is zig"));
    str_free(r2);
    str_free(h2);
}

test "unique_words" {
    const h = str_from("the cat and the dog and cat", 27);
    const r = str_unique_words(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "the cat and dog"));
    str_free(r);
    str_free(h);
}

test "from_binary" {
    const h = str_from("01001000 01101001", 17);
    const r = str_from_binary(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "Hi"));
    str_free(r);
    str_free(h);
}

test "swap_words" {
    const h = str_from("hello world foo", 15);
    const r = str_swap_words(h, 0, 2);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "foo world hello"));
    str_free(r);
    str_free(h);
}

test "to_pig_latin" {
    const h = str_from("hello world", 11);
    const r = str_to_pig_latin(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "ellohay orldway"));
    str_free(r);
    str_free(h);

    const h2 = str_from("apple is", 8);
    const r2 = str_to_pig_latin(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "appleyay isyay"));
    str_free(r2);
    str_free(h2);
}

test "run_length_encode" {
    const h = str_from("aaabbc", 6);
    const r = str_run_length_encode(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "3a2b1c"));
    str_free(r);
    str_free(h);

    const h2 = str_from("abc", 3);
    const r2 = str_run_length_encode(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "1a1b1c"));
    str_free(r2);
    str_free(h2);
}

test "run_length_decode" {
    const h = str_from("3a2b1c", 6);
    const r = str_run_length_decode(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "aaabbc"));
    str_free(r);
    str_free(h);
}

test "count_paragraphs" {
    const h1 = str_from("para1\n\npara2\n\npara3", 19);
    try std.testing.expectEqual(@as(c_int, 3), str_count_paragraphs(h1));
    str_free(h1);

    const h2 = str_from("single paragraph", 16);
    try std.testing.expectEqual(@as(c_int, 1), str_count_paragraphs(h2));
    str_free(h2);
}

test "zigzag" {
    const h = str_from("WEAREDISCOVERED", 15);
    const r = str_zigzag(h, 3);
    // Rail 0: W...E...C...R...  -> WECR (positions 0,4,8,12)
    // Rail 1: .A.R.D.S.O.E.E.  -> ARDSOEE (positions 1,3,5,7,9,11,13)
    // Rail 2: ..E...I...V...D  -> EIVD (positions 2,6,10,14)
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "WECRERDSOEEAIVD"));
    str_free(r);
    str_free(h);
}

test "to_morse" {
    const h = str_from("SOS", 3);
    const r = str_to_morse(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "... --- ..."));
    str_free(r);
    str_free(h);

    const h2 = str_from("HI", 2);
    const r2 = str_to_morse(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], ".... .."));
    str_free(r2);
    str_free(h2);
}

test "to_base64" {
    const h = str_from("Hello", 5);
    const r = str_to_base64(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "SGVsbG8="));
    str_free(r);
    str_free(h);

    const h2 = str_from("Hi", 2);
    const r2 = str_to_base64(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "SGk="));
    str_free(r2);
    str_free(h2);
}

test "from_base64" {
    const h = str_from("SGVsbG8=", 8);
    const r = str_from_base64(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "Hello"));
    str_free(r);
    str_free(h);
}

test "xor_cipher" {
    const h = str_from("ABC", 3);
    const r = str_xor_cipher(h, 0x20);
    // A(65)^32=97='a', B(66)^32=98='b', C(67)^32=99='c'
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "abc"));
    // XOR again to get back original
    const r2 = str_xor_cipher(r, 0x20);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "ABC"));
    str_free(r2);
    str_free(r);
    str_free(h);
}

test "entropy" {
    const h1 = str_from("aaaa", 4);
    try std.testing.expectEqual(@as(c_int, 0), str_entropy(h1));
    str_free(h1);

    // "ab" has entropy of 1.0 bit -> *100 = 100
    const h2 = str_from("ab", 2);
    try std.testing.expectEqual(@as(c_int, 100), str_entropy(h2));
    str_free(h2);
}

test "char_frequency_top" {
    const h = str_from("aabbbcc", 7);
    const r = str_char_frequency_top(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "b"));
    str_free(r);
    str_free(h);
}

test "jaccard_similarity" {
    const h1 = str_from("abc", 3);
    const h2 = str_from("abc", 3);
    try std.testing.expectEqual(@as(c_int, 100), str_jaccard_similarity(h1, h2));
    str_free(h2);
    str_free(h1);

    const h3 = str_from("abc", 3);
    const h4 = str_from("xyz", 3);
    try std.testing.expectEqual(@as(c_int, 0), str_jaccard_similarity(h3, h4));
    str_free(h4);
    str_free(h3);

    // "ab" and "bc" share 'b' -> intersection=1, union=3 -> 33%
    const h5 = str_from("ab", 2);
    const h6 = str_from("bc", 2);
    try std.testing.expectEqual(@as(c_int, 33), str_jaccard_similarity(h5, h6));
    str_free(h6);
    str_free(h5);
}

test "longest_common_prefix" {
    const h1 = str_from("hello world", 11);
    const h2 = str_from("hello there", 11);
    const r = str_longest_common_prefix(h1, h2);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "hello "));
    str_free(r);
    str_free(h2);
    str_free(h1);
}

test "longest_common_suffix" {
    const h1 = str_from("testing", 7);
    const h2 = str_from("resting", 7);
    const r = str_longest_common_suffix(h1, h2);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "esting"));
    str_free(r);
    str_free(h2);
    str_free(h1);
}

test "wrap_with" {
    const h = str_from("hello", 5);
    const r = str_wrap_with(h, "[", 1, "]", 1);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "[hello]"));
    str_free(r);
    str_free(h);
}

test "to_title_case_strict" {
    const h = str_from("hello world foo", 15);
    const r = str_to_title_case_strict(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "Hello World Foo"));
    str_free(r);
    str_free(h);

    const h2 = str_from("the LORD of war", 15);
    const r2 = str_to_title_case_strict(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "The Lord Of War"));
    str_free(r2);
    str_free(h2);
}

test "hamming_weight" {
    // 'A' = 0x41 = 01000001 = 2 bits, 'B' = 0x42 = 01000010 = 2 bits
    const h = str_from("AB", 2);
    try std.testing.expectEqual(@as(c_int, 4), str_hamming_weight(h));
    str_free(h);

    const h2 = str_from("", 0);
    try std.testing.expectEqual(@as(c_int, 0), str_hamming_weight(h2));
    str_free(h2);
}

test "is_palindrome_words" {
    const h1 = str_from("dog cat dog", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_is_palindrome_words(h1));
    str_free(h1);

    const h2 = str_from("a b c b a", 9);
    try std.testing.expectEqual(@as(c_int, 1), str_is_palindrome_words(h2));
    str_free(h2);

    const h3 = str_from("hello world", 11);
    try std.testing.expectEqual(@as(c_int, 0), str_is_palindrome_words(h3));
    str_free(h3);
}

test "remove_nth_word" {
    const h = str_from("hello world foo", 15);
    const r = str_remove_nth_word(h, 1);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "hello foo"));
    str_free(r);
    str_free(h);

    const h2 = str_from("hello world foo", 15);
    const r2 = str_remove_nth_word(h2, 0);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "world foo"));
    str_free(r2);
    str_free(h2);
}

test "insert_word_at" {
    const h = str_from("hello foo", 9);
    const r = str_insert_word_at(h, 1, "world", 5);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "hello world foo"));
    str_free(r);
    str_free(h);

    const h2 = str_from("world foo", 9);
    const r2 = str_insert_word_at(h2, 0, "hello", 5);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "hello world foo"));
    str_free(r2);
    str_free(h2);
}

test "to_spongebob_case" {
    const h = str_from("hello world", 11);
    const r = str_to_spongebob_case(h);
    // H(0)e(1)L(2)l(3)O(4) W(5)o(6)R(7)l(8)D(9) -> "HeLlO wOrLd"
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "HeLlO wOrLd"));
    str_free(r);
    str_free(h);
}

test "between_first" {
    const h = str_from("say [hello] world [bye]", 23);
    const r = str_between_first(h, "[", 1, "]", 1);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "hello"));
    str_free(r);
    str_free(h);

    const h2 = str_from("<b>hi</b>", 9);
    const r2 = str_between_first(h2, "<b>", 3, "</b>", 4);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "hi"));
    str_free(r2);
    str_free(h2);
}

test "to_dot_case" {
    const h = str_from("helloWorld", 10);
    const r = str_to_dot_case(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "hello.world"));
    str_free(r);
    str_free(h);

    const h2 = str_from("MyVarName", 9);
    const r2 = str_to_dot_case(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "my.var.name"));
    str_free(r2);
    str_free(h2);
}

test "abbreviate" {
    // abbreviate("hello world", 8) -> "hello..." (5 text + 3 dots = 8 total)
    const h = str_from("hello world", 11);
    const r = str_abbreviate(h, 8);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "hello..."));
    str_free(r);
    str_free(h);

    // abbreviate("hello world", 5) -> "he..." (2 text + 3 dots = 5 total)
    const h1b = str_from("hello world", 11);
    const r1b = str_abbreviate(h1b, 5);
    try std.testing.expect(mem.eql(u8, str_data(r1b)[0..@intCast(str_size(r1b))], "he..."));
    str_free(r1b);
    str_free(h1b);

    // shorter than limit -> returned as-is
    const h2 = str_from("hi", 2);
    const r2 = str_abbreviate(h2, 5);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "hi"));
    str_free(r2);
    str_free(h2);
}

test "count_substring" {
    const h = str_from("abcabcabc", 9);
    try std.testing.expectEqual(@as(c_int, 3), str_count_substring(h, "abc", 3));
    str_free(h);

    const h2 = str_from("aaa", 3);
    try std.testing.expectEqual(@as(c_int, 1), str_count_substring(h2, "aa", 2));
    str_free(h2);
}

test "to_path_case" {
    const h = str_from("helloWorld", 10);
    const r = str_to_path_case(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "hello/world"));
    str_free(r);
    str_free(h);
}

test "left_pad" {
    const h = str_from("42", 2);
    const r = str_left_pad(h, 5, '0');
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "00042"));
    str_free(r);
    str_free(h);

    // No padding needed when already wide enough
    const h2 = str_from("hello", 5);
    const r2 = str_left_pad(h2, 3, 'x');
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "hello"));
    str_free(r2);
    str_free(h2);
}

test "right_pad" {
    const h = str_from("hi", 2);
    const r = str_right_pad(h, 5, '.');
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "hi..."));
    str_free(r);
    str_free(h);
}

test "to_hex" {
    const h = str_from("ABC", 3);
    const r = str_to_hex(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "414243"));
    str_free(r);
    str_free(h);
}

test "from_hex" {
    const h = str_from("414243", 6);
    const r = str_from_hex(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "ABC"));
    str_free(r);
    str_free(h);
}

test "soundex" {
    const h = str_from("Robert", 6);
    const r = str_soundex(h);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "R163"));
    str_free(r);
    str_free(h);

    const h2 = str_from("Ashcraft", 8);
    const r2 = str_soundex(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "A261"));
    str_free(r2);
    str_free(h2);
}

test "vigenere_encrypt" {
    const h = str_from("hello", 5);
    const r = str_vigenere_encrypt(h, "key", 3);
    // h+k=r, e+e=i, l+y=j, l+k=v, o+e=s
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "rijvs"));
    str_free(r);
    str_free(h);
}

test "atbash" {
    const h = str_from("abc", 3);
    const r = str_atbash(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "zyx"));
    str_free(r);
    str_free(h);

    const h2 = str_from("Hello", 5);
    const r2 = str_atbash(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2.?)[0..@intCast(str_size(r2.?))], "Svool"));
    str_free(r2);
    str_free(h2);
}

test "count_words_matching" {
    const h = str_from("the cat and the dog", 19);
    try std.testing.expectEqual(@as(c_int, 2), str_count_words_matching(h, "the", 3));
    str_free(h);
}

test "truncate_words" {
    const h = str_from("one two three four five", 23);
    const r = str_truncate_words(h, 3);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "one two three"));
    str_free(r);
    str_free(h);
}

test "to_constant_case" {
    const h = str_from("hello world", 11);
    const r = str_to_constant_case(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "HELLO_WORLD"));
    str_free(r);
    str_free(h);

    const h2 = str_from("camelCase", 9);
    const r2 = str_to_constant_case(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2.?)[0..@intCast(str_size(r2.?))], "CAMEL_CASE"));
    str_free(r2);
    str_free(h2);
}

test "first_word" {
    const h = str_from("hello world foo", 15);
    const r = str_first_word(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "hello"));
    str_free(r);
    str_free(h);
}

test "last_word" {
    const h = str_from("hello world foo", 15);
    const r = str_last_word(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "foo"));
    str_free(r);
    str_free(h);
}

test "to_nato" {
    const h = str_from("AB", 2);
    const r = str_to_nato(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "Alfa Bravo"));
    str_free(r);
    str_free(h);
}

test "commonality" {
    const h1 = str_from("abc", 3);
    const h2 = str_from("bcd", 3);
    try std.testing.expectEqual(@as(c_int, 2), str_commonality(h1, h2));
    str_free(h1);
    str_free(h2);
}

test "diff_chars" {
    const h1 = str_from("abcd", 4);
    const h2 = str_from("bc", 2);
    const r = str_diff_chars(h1, h2);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "ad"));
    str_free(r);
    str_free(h1);
    str_free(h2);
}

test "rot47" {
    const h = str_from("Hello", 5);
    const r = str_rot47(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "w6==@"));
    str_free(r);
    str_free(h);
}

test "is_isogram" {
    const h1 = str_from("subdermatoglyphic", 17);
    try std.testing.expectEqual(@as(c_int, 1), str_is_isogram(h1));
    str_free(h1);

    const h2 = str_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_is_isogram(h2));
    str_free(h2);
}

test "reverse_each_word" {
    const h = str_from("hello world", 11);
    const r = str_reverse_each_word(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "olleh dlrow"));
    str_free(r);
    str_free(h);
}

test "count_digits" {
    const h = str_from("abc123def45", 11);
    try std.testing.expectEqual(@as(c_int, 5), str_count_digits(h));
    str_free(h);
}

test "strip_tags" {
    const h = str_from("<b>hello</b> <i>world</i>", 25);
    const r = str_strip_tags(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "hello world"));
    str_free(r);
    str_free(h);
}

test "to_slug" {
    const h = str_from("Hello World! Test", 17);
    const r = str_to_slug(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "hello-world-test"));
    str_free(r);
    str_free(h);
}

test "count_spaces" {
    const h = str_from("hello  world  foo", 17);
    try std.testing.expectEqual(@as(c_int, 4), str_count_spaces(h));
    str_free(h);
}

test "normalize_spaces" {
    const h = str_from("  hello   world  ", 17);
    const r = str_normalize_spaces(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "hello world"));
    str_free(r);
    str_free(h);
}

test "mask_email" {
    const h = str_from("john@example.com", 16);
    const r = str_mask_email(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "j***@example.com"));
    str_free(r);
    str_free(h);
}

test "pluralize" {
    const h1 = str_from("cat", 3);
    const r1 = str_pluralize(h1);
    try std.testing.expect(mem.eql(u8, str_data(r1.?)[0..@intCast(str_size(r1.?))], "cats"));
    str_free(r1);
    str_free(h1);

    const h2 = str_from("city", 4);
    const r2 = str_pluralize(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2.?)[0..@intCast(str_size(r2.?))], "cities"));
    str_free(r2);
    str_free(h2);

    const h3 = str_from("box", 3);
    const r3 = str_pluralize(h3);
    try std.testing.expect(mem.eql(u8, str_data(r3.?)[0..@intCast(str_size(r3.?))], "boxes"));
    str_free(r3);
    str_free(h3);
}

test "deduplicate_lines" {
    const input = "hello\nworld\nhello\nfoo";
    const h = str_from(input, input.len);
    const r = str_deduplicate_lines(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "hello\nworld\nfoo"));
    str_free(r);
    str_free(h);
}

test "remove_blank_lines" {
    const input = "hello\n\nworld\n  \nfoo";
    const h = str_from(input, input.len);
    const r = str_remove_blank_lines(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "hello\nworld\nfoo"));
    str_free(r);
    str_free(h);
}

test "extract_numbers" {
    const h = str_from("price is 42.5 and qty 10", 24);
    const r = str_extract_numbers(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "42.5 10"));
    str_free(r);
    str_free(h);
}

test "extract_emails" {
    const h = str_from("contact john@example.com or jane@test.org", 41);
    const r = str_extract_emails(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "john@example.com jane@test.org"));
    str_free(r);
    str_free(h);
}

test "quote" {
    const h = str_from("hello", 5);
    const r = str_quote(h, '"');
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "\"hello\""));
    str_free(r);
    str_free(h);
}

test "unquote" {
    const h = str_from("\"hello\"", 7);
    const r = str_unquote(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "hello"));
    str_free(r);
    str_free(h);

    const h2 = str_from("no quotes", 9);
    const r2 = str_unquote(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2.?)[0..@intCast(str_size(r2.?))], "no quotes"));
    str_free(r2);
    str_free(h2);
}

test "to_csv_field" {
    const h = str_from("hello,world", 11);
    const r = str_to_csv_field(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "\"hello,world\""));
    str_free(r);
    str_free(h);

    const h2 = str_from("simple", 6);
    const r2 = str_to_csv_field(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2.?)[0..@intCast(str_size(r2.?))], "simple"));
    str_free(r2);
    str_free(h2);
}

test "number_lines" {
    const input = "hello\nworld";
    const h = str_from(input, input.len);
    const r = str_number_lines(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "1: hello\n2: world"));
    str_free(r);
    str_free(h);
}

test "hide" {
    const h = str_from("1234567890", 10);
    const r = str_hide(h, '*', 2, 2);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "12******90"));
    str_free(r);
    str_free(h);
}

test "extract_words" {
    const h = str_from("hello, world! foo-bar 123", 25);
    const r = str_extract_words(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "hello world foo bar"));
    str_free(r);
    str_free(h);
}

test "expand_tabs" {
    const h = str_from("a\tb", 3);
    const r = str_expand_tabs(h, 4);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "a    b"));
    str_free(r);
    str_free(h);
}

test "sentence_count" {
    const h = str_from("Hello. How are you? Fine!", 25);
    try std.testing.expectEqual(@as(c_int, 3), str_sentence_count(h));
    str_free(h);
}

test "chop" {
    const h = str_from("hello", 5);
    const r = str_chop(h);
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..@intCast(str_size(r.?))], "hell"));
    str_free(r);
    str_free(h);
}

test "scan_int" {
    const h = str_from("42abc", 5);
    try std.testing.expectEqual(@as(c_int, 42), str_scan_int(h));
    str_free(h);

    const h2 = str_from("-7", 2);
    try std.testing.expectEqual(@as(c_int, -7), str_scan_int(h2));
    str_free(h2);
}

test "to_ordinal" {
    const h1 = str_from("1", 1);
    const r1 = str_to_ordinal(h1);
    try std.testing.expect(mem.eql(u8, str_data(r1.?)[0..@intCast(str_size(r1.?))], "1st"));
    str_free(r1);
    str_free(h1);

    const h2 = str_from("12", 2);
    const r2 = str_to_ordinal(h2);
    try std.testing.expect(mem.eql(u8, str_data(r2.?)[0..@intCast(str_size(r2.?))], "12th"));
    str_free(r2);
    str_free(h2);

    const h3 = str_from("23", 2);
    const r3 = str_to_ordinal(h3);
    try std.testing.expect(mem.eql(u8, str_data(r3.?)[0..@intCast(str_size(r3.?))], "23rd"));
    str_free(r3);
    str_free(h3);
}

test "left_cp" {
    const s = str_from("Hello", 5);
    const r = str_left_cp(s, 3);
    try std.testing.expectEqual(@as(usize, 3), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..3], "Hel"));
    str_free(r);
    str_free(s);
}

test "left_cp utf8" {
    // "cafe\xCC\x81" = "café" (5 bytes, 4 codepoints with combining accent)
    const s = str_from("caf\xC3\xA9!", 6); // café! = 5 codepoints
    const r = str_left_cp(s, 4); // "café"
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..5], "caf\xC3\xA9"));
    str_free(r);
    str_free(s);
}

test "right_cp" {
    const s = str_from("Hello", 5);
    const r = str_right_cp(s, 3);
    try std.testing.expectEqual(@as(usize, 3), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r.?)[0..3], "llo"));
    str_free(r);
    str_free(s);
}

test "cp_count" {
    const s1 = str_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 5), str_cp_count(s1));
    str_free(s1);

    const s2 = str_from("caf\xC3\xA9", 5); // café = 4 codepoints
    try std.testing.expectEqual(@as(c_int, 4), str_cp_count(s2));
    str_free(s2);
}

test "nth_char" {
    const s = str_from("caf\xC3\xA9!", 6); // café! = 5 codepoints
    const c0 = str_nth_char(s, 1); // 'c' (1-based)
    try std.testing.expectEqual(@as(usize, 1), str_size(c0));
    try std.testing.expect(mem.eql(u8, str_data(c0.?)[0..1], "c"));
    str_free(c0);

    const c3 = str_nth_char(s, 4); // 'é' (1-based)
    try std.testing.expectEqual(@as(usize, 2), str_size(c3));
    try std.testing.expect(mem.eql(u8, str_data(c3.?)[0..2], "\xC3\xA9"));
    str_free(c3);

    const c4 = str_nth_char(s, 5); // '!' (1-based)
    try std.testing.expectEqual(@as(usize, 1), str_size(c4));
    try std.testing.expect(mem.eql(u8, str_data(c4.?)[0..1], "!"));
    str_free(c4);

    str_free(s);
}

// ─── Unicode CI Tests ───

test "equals_ci unicode" {
    // German sharp-s: "strasse" should equal "STRASSE" case-insensitively
    const a = str_from("hello", 5);
    const b = str_from("HELLO", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_equals_ci(a, b));
    str_free(a);
    str_free(b);

    // French accented: "cafe" vs "CAFE" (basic)
    const c = str_from("caf\xC3\xA9", 5);
    const d = str_from("CAF\xC3\x89", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_equals_ci(c, d));
    str_free(c);
    str_free(d);
}

test "contains_ci unicode" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_contains_ci(s, "WORLD", 5));
    try std.testing.expectEqual(@as(c_int, 1), str_contains_ci(s, "hello", 5));
    try std.testing.expectEqual(@as(c_int, 0), str_contains_ci(s, "xyz", 3));
    str_free(s);
}

test "starts_with_ci unicode" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_starts_with_ci(s, "HELLO", 5));
    try std.testing.expectEqual(@as(c_int, 1), str_starts_with_ci(s, "hello", 5));
    try std.testing.expectEqual(@as(c_int, 0), str_starts_with_ci(s, "world", 5));
    str_free(s);
}

test "ends_with_ci unicode" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_ends_with_ci(s, "WORLD", 5));
    try std.testing.expectEqual(@as(c_int, 1), str_ends_with_ci(s, "world", 5));
    try std.testing.expectEqual(@as(c_int, 0), str_ends_with_ci(s, "hello", 5));
    str_free(s);
}

test "find_all_ci unicode" {
    const s = str_from("abcABCabc", 9);
    const r = str_find_all_ci(s, "abc", 3);
    try std.testing.expectEqual(@as(c_int, 3), stz_find_result_count(r));
    try std.testing.expectEqual(@as(i64, 1), stz_find_result_get(r, 0));
    try std.testing.expectEqual(@as(i64, 4), stz_find_result_get(r, 1));
    try std.testing.expectEqual(@as(i64, 7), stz_find_result_get(r, 2));
    stz_find_result_free(r);
    str_free(s);
}

test "count_of_ci unicode" {
    const s = str_from("abcABCabc", 9);
    try std.testing.expectEqual(@as(c_int, 3), str_count_of_ci(s, "abc", 3));
    str_free(s);
}

test "foldcase unicode" {
    const s = str_from("Hello WORLD", 11);
    const r = str_foldcase(s);
    const data = str_data(r);
    try std.testing.expect(mem.eql(u8, data[0..11], "hello world"));
    str_free(r);
    str_free(s);
}

test "trim_left unicode whitespace" {
    // U+00A0 (no-break space) = C2 A0 in UTF-8
    const s = str_from("\xC2\xA0 hello", 8);
    const r = str_trim_left(s);
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..5], "hello"));
    str_free(r);
    str_free(s);
}

test "trim_right unicode whitespace" {
    // U+00A0 (no-break space) = C2 A0 in UTF-8
    const s = str_from("hello \xC2\xA0", 8);
    const r = str_trim_right(s);
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..5], "hello"));
    str_free(r);
    str_free(s);
}

test "trimmed delegates to unicode trim" {
    // U+00A0 on both sides
    const s = str_from("\xC2\xA0hello\xC2\xA0", 9);
    const r = str_trimmed(s);
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..5], "hello"));
    str_free(r);
    str_free(s);
}

// ─── NLP Tests ───

test "jaro identical" {
    const a = str_from("hello", 5);
    const b = str_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 1000), str_jaro(a, b));
    str_free(a);
    str_free(b);
}

test "jaro similar" {
    const a = str_from("martha", 6);
    const b = str_from("marhta", 6);
    const j = str_jaro(a, b);
    // Jaro("martha", "marhta") should be ~944
    try std.testing.expect(j > 900 and j <= 1000);
    str_free(a);
    str_free(b);
}

test "jaro_winkler boosts prefix" {
    const a = str_from("martha", 6);
    const b = str_from("marhta", 6);
    const j = str_jaro(a, b);
    const jw = str_jaro_winkler(a, b);
    // Jaro-Winkler should be >= Jaro (prefix boost)
    try std.testing.expect(jw >= j);
    str_free(a);
    str_free(b);
}

test "jaro_winkler different strings" {
    const a = str_from("abc", 3);
    const b = str_from("xyz", 3);
    try std.testing.expectEqual(@as(c_int, 0), str_jaro_winkler(a, b));
    str_free(a);
    str_free(b);
}

test "metaphone basic" {
    const h = str_from("smith", 5);
    const r = str_metaphone(h);
    try std.testing.expect(r != null);
    const data = str_data(r.?);
    const size = str_size(r.?);
    // Metaphone of "smith" should be "SM0" (0 = theta for TH)
    try std.testing.expect(size > 0);
    try std.testing.expect(mem.eql(u8, data[0..size], "SM0"));
    str_free(r);
    str_free(h);
}

test "metaphone phone" {
    const h = str_from("phone", 5);
    const r = str_metaphone(h);
    try std.testing.expect(r != null);
    const data = str_data(r.?);
    const size = str_size(r.?);
    // PH -> F, so "phone" -> "FN"
    try std.testing.expect(mem.eql(u8, data[0..size], "FN"));
    str_free(r);
    str_free(h);
}

test "char_ngrams bigrams" {
    const h = str_from("hello", 5);
    const r = str_char_ngrams(h, 2);
    try std.testing.expect(r != null);
    const data = str_data(r.?);
    const size = str_size(r.?);
    try std.testing.expect(mem.eql(u8, data[0..size], "he|el|ll|lo"));
    str_free(r);
    str_free(h);
}

test "word_ngrams bigrams" {
    const input = "the quick brown fox";
    const h = str_from(input, input.len);
    const r = str_word_ngrams(h, 2);
    try std.testing.expect(r != null);
    const data = str_data(r.?);
    const size = str_size(r.?);
    try std.testing.expect(mem.eql(u8, data[0..size], "the quick|quick brown|brown fox"));
    str_free(r);
    str_free(h);
}

// ─── CS Merge Tests ───

test "index_of_cs case sensitive" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(i64, 7), str_index_of_cs(s, "World", 5, 1));
    try std.testing.expectEqual(@as(i64, -1), str_index_of_cs(s, "world", 5, 1));
    str_free(s);
}

test "index_of_cs case insensitive" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(i64, 7), str_index_of_cs(s, "WORLD", 5, 0));
    try std.testing.expectEqual(@as(i64, 1), str_index_of_cs(s, "hello", 5, 0));
    str_free(s);
}

test "find_all_cs" {
    const s = str_from("abcABCabc", 9);
    const r1 = str_find_all_cs(s, "abc", 3, 1);
    try std.testing.expectEqual(@as(c_int, 2), stz_find_result_count(r1));
    stz_find_result_free(r1);
    const r0 = str_find_all_cs(s, "abc", 3, 0);
    try std.testing.expectEqual(@as(c_int, 3), stz_find_result_count(r0));
    stz_find_result_free(r0);
    str_free(s);
}

test "contains_cs" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_contains_cs(s, "World", 5, 1));
    try std.testing.expectEqual(@as(c_int, 0), str_contains_cs(s, "world", 5, 1));
    try std.testing.expectEqual(@as(c_int, 1), str_contains_cs(s, "world", 5, 0));
    str_free(s);
}

test "equals_cs" {
    const a = str_from("Hello", 5);
    const b = str_from("hello", 5);
    try std.testing.expectEqual(@as(c_int, 0), str_equals_cs(a, b, 1));
    try std.testing.expectEqual(@as(c_int, 1), str_equals_cs(a, b, 0));
    str_free(a);
    str_free(b);
}

test "starts_with_cs ends_with_cs" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 0), str_starts_with_cs(s, "hello", 5, 1));
    try std.testing.expectEqual(@as(c_int, 1), str_starts_with_cs(s, "hello", 5, 0));
    try std.testing.expectEqual(@as(c_int, 0), str_ends_with_cs(s, "WORLD", 5, 1));
    try std.testing.expectEqual(@as(c_int, 1), str_ends_with_cs(s, "WORLD", 5, 0));
    str_free(s);
}

test "find_nth_cs" {
    const s = str_from("aXaXaXa", 7);
    try std.testing.expectEqual(@as(i64, 2), str_find_nth_cs(s, "X", 1, 1, 1));
    try std.testing.expectEqual(@as(i64, 6), str_find_nth_cs(s, "X", 1, 3, 1));
    str_free(s);
}

test "last_index_of_cs" {
    const s = str_from("abcABCabc", 9);
    try std.testing.expectEqual(@as(i64, 7), str_last_index_of_cs(s, "abc", 3, 1));
    try std.testing.expectEqual(@as(i64, 7), str_last_index_of_cs(s, "abc", 3, 0)); // last CI match at pos 7
    str_free(s);
}

test "count_of_cs" {
    const s = str_from("abcABCabc", 9);
    try std.testing.expectEqual(@as(c_int, 2), str_count_of_cs(s, "abc", 3, 1));
    try std.testing.expectEqual(@as(c_int, 3), str_count_of_cs(s, "abc", 3, 0));
    str_free(s);
}

// ─── Phase B: Safety & Robustness Tests ───

test "str_last_error initial state" {
    try std.testing.expectEqual(@as(c_int, 0), str_last_error());
}

test "str_clear_error" {
    // Force an error, then clear
    _ = str_from("\xff\xfe", 2); // invalid UTF-8
    try std.testing.expect(str_last_error() != 0);
    str_clear_error();
    try std.testing.expectEqual(@as(c_int, 0), str_last_error());
}

test "str_from rejects invalid UTF-8" {
    // Invalid continuation byte
    const bad1 = str_from("\xff\xfe", 2);
    try std.testing.expect(bad1 == null);
    try std.testing.expectEqual(@as(c_int, 2), str_last_error()); // invalid_utf8

    // Overlong encoding
    const bad2 = str_from("\xc0\x80", 2);
    try std.testing.expect(bad2 == null);
    try std.testing.expectEqual(@as(c_int, 2), str_last_error());

    // Truncated sequence
    const bad3 = str_from("\xe2\x82", 2);
    try std.testing.expect(bad3 == null);
    try std.testing.expectEqual(@as(c_int, 2), str_last_error());

    // Valid UTF-8 should succeed and clear error
    const good = str_from("Hello", 5);
    try std.testing.expect(good != null);
    try std.testing.expectEqual(@as(c_int, 0), str_last_error());
    str_free(good);
}

test "str_from accepts valid multi-byte UTF-8" {
    // 2-byte: e with acute
    const s2 = str_from("\xc3\xa9", 2);
    try std.testing.expect(s2 != null);
    try std.testing.expectEqual(@as(c_int, 0), str_last_error());
    str_free(s2);

    // 3-byte: Euro sign
    const s3 = str_from("\xe2\x82\xac", 3);
    try std.testing.expect(s3 != null);
    str_free(s3);

    // 4-byte: emoji
    const s4 = str_from("\xf0\x9f\x98\x80", 4);
    try std.testing.expect(s4 != null);
    str_free(s4);
}

test "str_from null pointer with len 0 succeeds" {
    const s = str_from(null, 0);
    try std.testing.expect(s != null);
    try std.testing.expectEqual(@as(c_int, 0), str_last_error());
    try std.testing.expectEqual(@as(usize, 0), str_size(s));
    str_free(s);
}

test "str_from null pointer with len > 0 fails" {
    const s = str_from(null, 5);
    try std.testing.expect(s == null);
    try std.testing.expectEqual(@as(c_int, 5), str_last_error()); // invalid_argument
}

test "str_data null-terminated" {
    const s = str_from("Hello", 5);
    const data = str_data(s);
    // The 6th byte (index 5) should be '\0' for C compatibility
    try std.testing.expectEqual(@as(u8, 0), data[5]);
    str_free(s);
}

test "str_data empty string returns empty" {
    const s = str_new();
    const data = str_data(s);
    try std.testing.expectEqual(@as(u8, 0), data[0]);
    str_free(s);
}

test "str_data null handle returns empty" {
    const data = str_data(null);
    try std.testing.expectEqual(@as(u8, 0), data[0]);
}

test "str_append sets error on null handle" {
    str_append(null, "test", 4);
    try std.testing.expectEqual(@as(c_int, 4), str_last_error()); // null_handle
}

test "str_insert sets error on null handle" {
    str_insert(null, 0, "test", 4);
    try std.testing.expectEqual(@as(c_int, 4), str_last_error()); // null_handle
}

test "error enum values" {
    // Verify the enum constants match the documented values
    try std.testing.expectEqual(@as(c_int, 0), @intFromEnum(StrError.none));
    try std.testing.expectEqual(@as(c_int, 1), @intFromEnum(StrError.out_of_memory));
    try std.testing.expectEqual(@as(c_int, 2), @intFromEnum(StrError.invalid_utf8));
    try std.testing.expectEqual(@as(c_int, 3), @intFromEnum(StrError.index_out_of_bounds));
    try std.testing.expectEqual(@as(c_int, 4), @intFromEnum(StrError.null_handle));
    try std.testing.expectEqual(@as(c_int, 5), @intFromEnum(StrError.invalid_argument));
}

// ─── Phase C: Performance Tests ───

test "cpCount cache works" {
    const s = str_from("Hello", 5);
    // First call computes; second should use cache
    try std.testing.expectEqual(@as(usize, 5), str_count(s));
    try std.testing.expectEqual(@as(usize, 5), str_count(s));
    str_free(s);
}

test "cpCount cache invalidated on append" {
    const s = str_from("Hi", 2);
    try std.testing.expectEqual(@as(usize, 2), str_count(s));
    str_append(s, " there", 6);
    try std.testing.expectEqual(@as(usize, 8), str_count(s));
    str_free(s);
}

test "isAscii cache works" {
    const s = str_from("Hello", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_is_ascii(s));
    // Should use cached value
    try std.testing.expectEqual(@as(c_int, 1), str_is_ascii(s));
    str_free(s);
}

test "isAscii detects non-ASCII" {
    const s = str_from("\xc3\xa9", 2); // e with acute
    try std.testing.expectEqual(@as(c_int, 0), str_is_ascii(s));
    str_free(s);
}

test "isAscii cache invalidated on append" {
    const s = str_from("Hi", 2);
    try std.testing.expectEqual(@as(c_int, 1), str_is_ascii(s));
    str_append(s, "\xc3\xa9", 2); // append non-ASCII
    try std.testing.expectEqual(@as(c_int, 0), str_is_ascii(s));
    str_free(s);
}

test "BMH search basic" {
    // Verify BMH finds correct positions
    const hay = "The quick brown fox jumps over the lazy dog";
    try std.testing.expectEqual(@as(?usize, 16), bmhSearch(hay, "fox j", 0));
    try std.testing.expectEqual(@as(?usize, 31), bmhSearch(hay, "the lazy", 0));
    try std.testing.expect(bmhSearch(hay, "cat jumps", 0) == null);
}

test "BMH search with start offset" {
    const hay = "abcdef abcdef abcdef";
    try std.testing.expectEqual(@as(?usize, 0), bmhSearch(hay, "abcdef", 0));
    try std.testing.expectEqual(@as(?usize, 7), bmhSearch(hay, "abcdef", 1));
    try std.testing.expectEqual(@as(?usize, 14), bmhSearch(hay, "abcdef", 8));
}

test "index_of uses BMH for long ASCII needles" {
    // Needle > 4 bytes, ASCII string -- should use BMH path
    const s = str_from("The quick brown fox jumps over the lazy dog", 43);
    try std.testing.expectEqual(@as(i64, 17), str_index_of(s, "fox j", 5)); // 1-based
    try std.testing.expectEqual(@as(i64, 32), str_index_of(s, "the lazy", 8)); // 1-based
    try std.testing.expectEqual(@as(i64, -1), str_index_of(s, "cat jumps", 9));
    str_free(s);
}

test "cpCount ASCII fast-path" {
    // ASCII: codepoint count == byte count
    const s = str_from("Hello World!", 12);
    try std.testing.expectEqual(@as(usize, 12), str_count(s));
    str_free(s);
}

test "cpCount multi-byte correct" {
    // "cafe" with accented e = 5 codepoints, 6 bytes
    const s = str_from("caf\xc3\xa9!", 6);
    try std.testing.expectEqual(@as(usize, 5), str_count(s));
    try std.testing.expectEqual(@as(usize, 6), str_size(s));
    str_free(s);
}

test "isAllAscii helper" {
    try std.testing.expect(isAllAscii("Hello World"));
    try std.testing.expect(!isAllAscii("\xc3\xa9"));
    try std.testing.expect(isAllAscii(""));
    try std.testing.expect(!isAllAscii("Hi\xf0\x9f\x98\x80"));
}
