// Softanza Engine -- String Operations (Tier 1)
//
// Pure re-export hub + integration tests. Shared infrastructure
// (types, lifecycle, helpers) lives in string/core.zig.
//
// All domain functions live in submodules under string/.
// This file re-exports their public API as a flat namespace
// and holds the integration test suite.

const std = @import("std");

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
// toLowerAscii removed -- all CI paths use casefoldAlloc/ciEqlUnicode now
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
pub const str_sha256 = encode.str_sha256;
pub const str_md5 = encode.str_md5;
pub const str_blake3 = encode.str_blake3;
pub const str_hmac_sha256 = encode.str_hmac_sha256;
pub const str_sha256_raw = encode.str_sha256_raw;

// ─── Locale submodule imports ───
const locale = @import("string/locale.zig");

pub const str_detect_script = locale.str_detect_script;
pub const str_script_name = locale.str_script_name;
pub const str_detect_direction = locale.str_detect_direction;
pub const str_direction_name = locale.str_direction_name;
pub const str_has_rtl = locale.str_has_rtl;
pub const str_script_count = locale.str_script_count;
pub const str_locale_compare = locale.str_locale_compare;

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
pub const StzWordFreqResultHandle = nlp.StzWordFreqResultHandle;
pub const str_word_freq = nlp.str_word_freq;
pub const str_char_freq = nlp.str_char_freq;
pub const str_word_ngram_freq = nlp.str_word_ngram_freq;
pub const str_count_word_cs = nlp.str_count_word_cs;
pub const str_numbers_agg = nlp.str_numbers_agg;
pub const str_sentence_stat = nlp.str_sentence_stat;
pub const str_edit_cluster = nlp.str_edit_cluster;
pub const str_collocations = nlp.str_collocations;
pub const str_tfidf_keywords = nlp.str_tfidf_keywords;
pub const stz_word_freq_count = nlp.stz_word_freq_count;
pub const stz_word_freq_word = nlp.stz_word_freq_word;
pub const stz_word_freq_num = nlp.stz_word_freq_num;
pub const stz_word_freq_free = nlp.stz_word_freq_free;
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
pub const str_split_get_cs = split.str_split_get_cs;
pub const str_split_all_cs = split.str_split_all_cs;
pub const str_lines_count = split.str_lines_count;
pub const str_lines_split_count = split.str_lines_split_count;
pub const str_line_at = split.str_line_at;
pub const str_count_lines = split.str_count_lines;
pub const str_sort_lines_cs = split.str_sort_lines_cs;
pub const str_sort_lines = split.str_sort_lines;
pub const str_unique_lines_cs = split.str_unique_lines_cs;
pub const str_unique_lines = split.str_unique_lines;
pub const str_reverse_lines = split.str_reverse_lines;
pub const str_word_count = split.str_word_count;
pub const str_count_words = split.str_count_words;
pub const str_word_at = split.str_word_at;
pub const str_nth_word = split.str_nth_word;
pub const str_first_word = split.str_first_word;
pub const str_last_word = split.str_last_word;
pub const str_swap_words = split.str_swap_words;
pub const str_sentence_count = split.str_sentence_count;
pub const str_partition_cs = split.str_partition_cs;
pub const str_partition = split.str_partition;
pub const str_partition_after_cs = split.str_partition_after_cs;
pub const str_partition_after = split.str_partition_after;
pub const str_rpartition_cs = split.str_rpartition_cs;
pub const str_rpartition = split.str_rpartition;
pub const str_rpartition_after_cs = split.str_rpartition_after_cs;
pub const str_rpartition_after = split.str_rpartition_after;
pub const str_chunk = split.str_chunk;
pub const str_chars_split = split.str_chars_split;
pub const str_words_split = split.str_words_split;
pub const str_sort_null_items_cs = split.str_sort_null_items_cs;
pub const str_sort_null_items = split.str_sort_null_items;
pub const str_unique_null_items_cs = split.str_unique_null_items_cs;
pub const str_unique_null_items = split.str_unique_null_items;

// ─── Find submodule imports ───
const find = @import("string/find.zig");

pub const str_find_first_cs = find.str_find_first_cs;
pub const str_find_first = find.str_find_first;
pub const str_find_first_from_cs = find.str_find_first_from_cs;
pub const str_find_first_from = find.str_find_first_from;
pub const str_byte_to_cp = find.str_byte_to_cp;
pub const str_count_of = find.str_count_of;
pub const str_count_of_cs = find.str_count_of_cs;
pub const str_find_cs = find.str_find_cs;
pub const str_find = find.str_find;
pub const stz_find_result_count = find.stz_find_result_count;
pub const stz_find_result_get = find.stz_find_result_get;
pub const stz_find_result_free = find.stz_find_result_free;
pub const str_find_dupsecutive_chars_cs = find.str_find_dupsecutive_chars_cs;
pub const str_find_dupsecutive_substring_cs = find.str_find_dupsecutive_substring_cs;
pub const StzStrListResultHandle = core.StzStrListResultHandle;
pub const stz_strlist_count = core.stz_strlist_count;
pub const stz_strlist_get = core.stz_strlist_get;
pub const stz_strlist_free = core.stz_strlist_free;
pub const str_substrings = extract.str_substrings;
pub const str_substrings_unique_cs = extract.str_substrings_unique_cs;
pub const str_substrings_by_count_cs = extract.str_substrings_by_count_cs;
pub const str_consecutive_substrings_of_n = extract.str_consecutive_substrings_of_n;
pub const str_consecutive_substrings = extract.str_consecutive_substrings;
pub const str_windows_upto_half = extract.str_windows_upto_half;
pub const str_find_last_cs = find.str_find_last_cs;
pub const str_find_last = find.str_find_last;
pub const str_contains_cs = find.str_contains_cs;
pub const str_contains = find.str_contains;
pub const str_starts_with_cs = find.str_starts_with_cs;
pub const str_starts_with = find.str_starts_with;
pub const str_ends_with_cs = find.str_ends_with_cs;
pub const str_ends_with = find.str_ends_with;
pub const str_equals_cs = find.str_equals_cs;
pub const str_equals = find.str_equals;
pub const str_find_nth_cs = find.str_find_nth_cs;
pub const str_find_nth = find.str_find_nth;
pub const str_starts_with_digit = find.str_starts_with_digit;
pub const str_starts_with_letter = find.str_starts_with_letter;
pub const str_ends_with_digit = find.str_ends_with_digit;
pub const str_ends_with_letter = find.str_ends_with_letter;
pub const str_find_char = find.str_find_char;
pub const str_starts_with_any_cs = find.str_starts_with_any_cs;
pub const str_starts_with_any = find.str_starts_with_any;
pub const str_ends_with_any_cs = find.str_ends_with_any_cs;
pub const str_ends_with_any = find.str_ends_with_any;
pub const str_duplicate_substrings_cs = find.str_duplicate_substrings_cs;
pub const str_between_first_cs = find.str_between_first_cs;
pub const str_section_cp = find.str_section_cp;

// ─── Replace submodule imports ───
const replace = @import("string/replace.zig");

pub const str_replace_range = replace.str_replace_range;
pub const str_replace_cs = replace.str_replace_cs;
pub const str_replace = replace.str_replace;
pub const str_replace_many_cs = replace.str_replace_many_cs;
pub const str_replace_first_cs = replace.str_replace_first_cs;
pub const str_replace_first = replace.str_replace_first;
pub const str_replace_last_cs = replace.str_replace_last_cs;
pub const str_replace_last = replace.str_replace_last;
pub const str_replace_nth_cs = replace.str_replace_nth_cs;
pub const str_replace_nth = replace.str_replace_nth;
pub const str_replace_char_at = replace.str_replace_char_at;
pub const str_replace_substring = replace.str_replace_substring;
pub const str_replace_char = replace.str_replace_char;
pub const str_replace_at = replace.str_replace_at;
pub const str_replace2 = replace.str_replace2;
pub const str_replace_any_char = replace.str_replace_any_char;
pub const str_replace_between = replace.str_replace_between;
pub const str_replace_first_between = replace.str_replace_first_between;
pub const str_replace_nth_between = replace.str_replace_nth_between;
pub const str_replace_last_between = replace.str_replace_last_between;
pub const str_remove_range = replace.str_remove_range;
pub const str_remove_cs = replace.str_remove_cs;
pub const str_remove = replace.str_remove;
pub const str_remove_char_at = replace.str_remove_char_at;
pub const str_remove_chars_of_type = replace.str_remove_chars_of_type;
pub const str_remove_consecutive_duplicates = replace.str_remove_consecutive_duplicates;
pub const str_remove_first = replace.str_remove_first;
pub const str_remove_last = replace.str_remove_last;
pub const str_remove_nth = replace.str_remove_nth;
pub const str_remove_prefix = replace.str_remove_prefix;
pub const str_remove_suffix = replace.str_remove_suffix;
pub const str_remove_whitespace = replace.str_remove_whitespace;
pub const str_remove_between = replace.str_remove_between;
pub const str_remove_first_between = replace.str_remove_first_between;
pub const str_remove_nth_between = replace.str_remove_nth_between;
pub const str_remove_last_between = replace.str_remove_last_between;
pub const str_remove_vowels = replace.str_remove_vowels;
pub const str_remove_duplicate_words = replace.str_remove_duplicate_words;
pub const str_remove_punctuation = replace.str_remove_punctuation;
pub const str_remove_nth_word = replace.str_remove_nth_word;
pub const str_remove_blank_lines = replace.str_remove_blank_lines;
pub const str_insert_cp = replace.str_insert_cp;
pub const str_insert_before_each = replace.str_insert_before_each;
pub const str_insert_after_each = replace.str_insert_after_each;
pub const str_insert_before_each_cs = replace.str_insert_before_each_cs;
pub const str_insert_after_each_cs = replace.str_insert_after_each_cs;
pub const str_insert_word_at = replace.str_insert_word_at;
pub const str_strip_chars = replace.str_strip_chars;
pub const str_keep_chars = replace.str_keep_chars;

// ─── Transform submodule imports ───
const transform = @import("string/transform.zig");

pub const str_to_upper = transform.str_to_upper;
pub const str_to_lower = transform.str_to_lower;
pub const str_dotless = transform.str_dotless;
pub const str_group_insert = transform.str_group_insert;
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
pub const str_contains_any_of_cs = inspect.str_contains_any_of_cs;
pub const str_contains_any_of = inspect.str_contains_any_of;
pub const str_contains_all_of_cs = inspect.str_contains_all_of_cs;
pub const str_contains_all_of = inspect.str_contains_all_of;
pub const str_is_alphanumeric = inspect.str_is_alphanumeric;
pub const str_is_digit = inspect.str_is_digit;
pub const str_is_blank = inspect.str_is_blank;
pub const str_is_identifier = inspect.str_is_identifier;
pub const str_contains_only_cs = inspect.str_contains_only_cs;
pub const str_contains_only = inspect.str_contains_only;
pub const str_is_anagram_cs = inspect.str_is_anagram_cs;
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
pub const str_contains_latin = inspect.str_contains_latin;
pub const str_contains_arabic = inspect.str_contains_arabic;
pub const str_has_mixed_case = inspect.str_has_mixed_case;
pub const str_is_punctuation = inspect.str_is_punctuation;
pub const str_is_symbol = inspect.str_is_symbol;
pub const str_is_mark = inspect.str_is_mark;
pub const str_is_control = inspect.str_is_control;
pub const str_has_punctuation = inspect.str_has_punctuation;
pub const str_has_symbol = inspect.str_has_symbol;
pub const str_has_mark = inspect.str_has_mark;

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
pub const str_between_last = extract.str_between_last;
pub const str_count_between = extract.str_count_between;
pub const str_substring = extract.str_substring;
pub const str_chars_between = extract.str_chars_between;
pub const str_char_at_to_string = extract.str_char_at_to_string;
pub const str_between_cs = extract.str_between_cs;
pub const str_between_first = extract.str_between_first;
pub const str_between_all = extract.str_between_all;
pub const str_between_all_cs = extract.str_between_all_cs;
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

const compare = @import("string/compare.zig");

pub const str_compare_cs = compare.str_compare_cs;
pub const str_compare = compare.str_compare;
pub const str_prefix_count_cs = compare.str_prefix_count_cs;
pub const str_prefix_count = compare.str_prefix_count;
pub const str_suffix_count_cs = compare.str_suffix_count_cs;
pub const str_suffix_count = compare.str_suffix_count;
pub const str_common_prefix_cs = compare.str_common_prefix_cs;
pub const str_common_prefix = compare.str_common_prefix;
pub const str_common_suffix_cs = compare.str_common_suffix_cs;
pub const str_common_suffix = compare.str_common_suffix;
pub const str_common_chars_cs = compare.str_common_chars_cs;
pub const str_common_chars = compare.str_common_chars;
pub const str_longest_common_prefix_cs = compare.str_longest_common_prefix_cs;
pub const str_longest_common_prefix = compare.str_longest_common_prefix;
pub const str_longest_common_suffix_cs = compare.str_longest_common_suffix_cs;
pub const str_longest_common_suffix = compare.str_longest_common_suffix;
pub const str_hamming_weight = compare.str_hamming_weight;
pub const str_commonality_cs = compare.str_commonality_cs;
pub const str_commonality = compare.str_commonality;
pub const str_diff_chars_cs = compare.str_diff_chars_cs;
pub const str_diff_chars = compare.str_diff_chars;

const counting = @import("string/count.zig");

pub const str_count_chars_of_type = counting.str_count_chars_of_type;
pub const str_find_chars_of_type = counting.str_find_chars_of_type;
pub const str_extract_chars_of_type = counting.str_extract_chars_of_type;
pub const str_char_type_at = counting.str_char_type_at;
pub const str_unique_chars = counting.str_unique_chars;
pub const str_duplicated_chars = counting.str_duplicated_chars;
pub const str_unique_char_count = counting.str_unique_char_count;
pub const str_count_leading_char = counting.str_count_leading_char;
pub const str_count_trailing_char = counting.str_count_trailing_char;
pub const str_count_char = counting.str_count_char;
pub const str_count_overlapping = counting.str_count_overlapping;
pub const str_count_any_char = counting.str_count_any_char;
pub const str_count_runs = counting.str_count_runs;
pub const str_count_vowels = counting.str_count_vowels;
pub const str_count_consonants = counting.str_count_consonants;
pub const str_longest_run = counting.str_longest_run;
pub const str_count_sentences = counting.str_count_sentences;
pub const str_digit_sum = counting.str_digit_sum;
pub const str_count_upper = counting.str_count_upper;
pub const str_count_lower = counting.str_count_lower;
pub const str_count_unique_chars = counting.str_count_unique_chars;
pub const str_count_paragraphs = counting.str_count_paragraphs;
pub const str_count_substring = counting.str_count_substring;
pub const str_count_words_matching = counting.str_count_words_matching;
pub const str_count_digits = counting.str_count_digits;
pub const str_count_spaces = counting.str_count_spaces;
pub const str_count_letters = counting.str_count_letters;
pub const str_count_punctuation = counting.str_count_punctuation;
pub const str_count_symbols = counting.str_count_symbols;
pub const str_count_marks = counting.str_count_marks;
pub const str_count_controls = counting.str_count_controls;
pub const str_count_arabic = counting.str_count_arabic;
pub const str_count_latin = counting.str_count_latin;
pub const str_count_greek = counting.str_count_greek;
pub const str_count_cyrillic = counting.str_count_cyrillic;
pub const str_count_hebrew = counting.str_count_hebrew;
pub const str_count_arabic_letters = counting.str_count_arabic_letters;
pub const str_count_latin_letters = counting.str_count_latin_letters;
pub const str_is_arabic = counting.str_is_arabic;
pub const str_is_latin = counting.str_is_latin;
pub const str_is_arabic_letters = counting.str_is_arabic_letters;
pub const str_is_latin_letters = counting.str_is_latin_letters;
pub const str_only_arabic = counting.str_only_arabic;
pub const str_only_latin = counting.str_only_latin;
pub const str_only_arabic_letters = counting.str_only_arabic_letters;
pub const str_only_latin_letters = counting.str_only_latin_letters;
pub const str_is_greek = counting.str_is_greek;
pub const str_is_cyrillic = counting.str_is_cyrillic;
pub const str_is_hebrew = counting.str_is_hebrew;
pub const str_has_arabic = counting.str_has_arabic;
pub const str_has_latin = counting.str_has_latin;
pub const str_has_greek = counting.str_has_greek;
pub const str_has_cyrillic = counting.str_has_cyrillic;
pub const str_has_hebrew = counting.str_has_hebrew;
pub const str_count_cjk = counting.str_count_cjk;
pub const str_count_devanagari = counting.str_count_devanagari;
pub const str_count_thai = counting.str_count_thai;
pub const str_char_unicode_at = counting.str_char_unicode_at;
pub const str_char_category_at = counting.str_char_category_at;
pub const str_char_category_string_at = counting.str_char_category_string_at;
pub const str_char_is_punctuation_at = counting.str_char_is_punctuation_at;
pub const str_char_is_symbol_at = counting.str_char_is_symbol_at;
pub const str_char_is_mark_at = counting.str_char_is_mark_at;
pub const str_char_is_control_at = counting.str_char_is_control_at;
pub const str_char_is_space_at = counting.str_char_is_space_at;

const format = @import("string/format.zig");

// Structural transforms
pub const str_reverse = format.str_reverse;
pub const str_repeat = format.str_repeat;
pub const str_concat = format.str_concat;
pub const str_copy = format.str_copy;
pub const str_sort_chars_asc = format.str_sort_chars_asc;
pub const str_sort_chars_desc = format.str_sort_chars_desc;
pub const str_repeat_char = format.str_repeat_char;
pub const str_rotate = format.str_rotate;
pub const str_repeat_to_length = format.str_repeat_to_length;
pub const str_swap_chars = format.str_swap_chars;
pub const str_mirror = format.str_mirror;
pub const str_repeat_each_char = format.str_repeat_each_char;

// Formatting / presentation
pub const str_spacify = format.str_spacify;
pub const str_bytes_per_char = format.str_bytes_per_char;
pub const str_char_frequency = format.str_char_frequency;
pub const str_truncate = format.str_truncate;
pub const str_wrap_at = format.str_wrap_at;
pub const str_ensure_prefix_cs = format.str_ensure_prefix_cs;
pub const str_ensure_prefix = format.str_ensure_prefix;
pub const str_ensure_suffix_cs = format.str_ensure_suffix_cs;
pub const str_ensure_suffix = format.str_ensure_suffix;
pub const str_only_letters = format.str_only_letters;
pub const str_only_digits = format.str_only_digits;
pub const str_only_vowels = format.str_only_vowels;
pub const str_only_punctuation = format.str_only_punctuation;
pub const str_only_symbols = format.str_only_symbols;
pub const str_only_spaces = format.str_only_spaces;
pub const str_only_marks = format.str_only_marks;
pub const str_only_controls = format.str_only_controls;
pub const str_interleave = format.str_interleave;
pub const str_surround = format.str_surround;
pub const str_mask = format.str_mask;
pub const str_slug = format.str_slug;
pub const str_camel_to_words = format.str_camel_to_words;
pub const str_initials = format.str_initials;
pub const str_title_smart = format.str_title_smart;
pub const str_char_frequency_top = format.str_char_frequency_top;
pub const str_wrap_with = format.str_wrap_with;
pub const str_abbreviate = format.str_abbreviate;
pub const str_strip_tags = format.str_strip_tags;
pub const str_to_slug = format.str_to_slug;
pub const str_deduplicate_lines_cs = format.str_deduplicate_lines_cs;
pub const str_deduplicate_lines = format.str_deduplicate_lines;
pub const str_number_lines = format.str_number_lines;
pub const str_hide = format.str_hide;
pub const str_chop = format.str_chop;
pub const str_scan_int = format.str_scan_int;
pub const str_to_ordinal = format.str_to_ordinal;
pub const str_truncate_words = format.str_truncate_words;

// Word-level operations
pub const str_reverse_words = format.str_reverse_words;
pub const str_sort_words_cs = format.str_sort_words_cs;
pub const str_sort_words = format.str_sort_words;
pub const str_unique_words_cs = format.str_unique_words_cs;
pub const str_unique_words = format.str_unique_words;
pub const str_run_length_encode = format.str_run_length_encode;
pub const str_run_length_decode = format.str_run_length_decode;
pub const str_reverse_each_word = format.str_reverse_each_word;
pub const str_all_substrings_cs = format.str_all_substrings_cs;
pub const str_unique_chars_cs = format.str_unique_chars_cs;
pub const str_substrings_count = format.str_substrings_count;
pub const str_substrings_of_n_chars = format.str_substrings_of_n_chars;

// ─── Regex submodule imports ───
const regex = @import("string/regex.zig");

pub const str_regex_is_match = regex.str_regex_is_match;
pub const str_regex_count = regex.str_regex_count;
pub const str_regex_find_first = regex.str_regex_find_first;
pub const str_regex_find_all = regex.str_regex_find_all;
pub const str_regex_extract_all = regex.str_regex_extract_all;
pub const str_regex_replace_all = regex.str_regex_replace_all;
pub const str_regex_split_count = regex.str_regex_split_count;
pub const str_regex_split_get = regex.str_regex_split_get;

test {
    _ = encode;
    _ = locale;
    _ = nlp;
    _ = split;
    _ = find;
    _ = replace;
    _ = transform;
    _ = inspect;
    _ = extract;
    _ = trim;
    _ = compare;
    _ = counting;
    _ = format;
    _ = regex;
}

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

    try std.testing.expectEqual(@as(i64, 7), str_find_first(s, "Ring", 4));
    try std.testing.expectEqual(@as(i64, -1), str_find_first(s, "Zig", 3));
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

test "string find_first_from" {
    const s = str_from("abcabcabc", 9);
    try std.testing.expectEqual(@as(i64, 1), str_find_first_from(s, "abc", 3, 1));
    try std.testing.expectEqual(@as(i64, 4), str_find_first_from(s, "abc", 3, 2));
    try std.testing.expectEqual(@as(i64, 7), str_find_first_from(s, "abc", 3, 5));
    try std.testing.expectEqual(@as(i64, -1), str_find_first_from(s, "abc", 3, 8));
    str_free(s);
}

test "string find_first_from_ci" {
    const s = str_from("Hello WORLD", 11);
    try std.testing.expectEqual(@as(i64, 1), str_find_first_from_cs(s, "hello", 5, 1, 0));
    try std.testing.expectEqual(@as(i64, 7), str_find_first_from_cs(s, "world", 5, 1, 0));
    try std.testing.expectEqual(@as(i64, -1), str_find_first_from_cs(s, "xyz", 3, 1, 0));
    try std.testing.expectEqual(@as(i64, 7), str_find_first_from_cs(s, "WORLD", 5, 4, 0));
    str_free(s);
}

test "string find" {
    const s = str_from("ring is ring and ring", 21);
    const r = str_find(s, "ring", 4);
    try std.testing.expectEqual(@as(c_int, 3), stz_find_result_count(r));
    try std.testing.expectEqual(@as(i64, 1), stz_find_result_get(r, 1));
    try std.testing.expectEqual(@as(i64, 9), stz_find_result_get(r, 2));
    try std.testing.expectEqual(@as(i64, 18), stz_find_result_get(r, 3));
    stz_find_result_free(r);

    // Not found
    const r2 = str_find(s, "xyz", 3);
    try std.testing.expectEqual(@as(c_int, 0), stz_find_result_count(r2));
    stz_find_result_free(r2);
    str_free(s);
}

test "string find_ci" {
    const s = str_from("Ring RING ring", 14);
    const r = str_find_cs(s, "ring", 4, 0);
    try std.testing.expectEqual(@as(c_int, 3), stz_find_result_count(r));
    try std.testing.expectEqual(@as(i64, 1), stz_find_result_get(r, 1));
    try std.testing.expectEqual(@as(i64, 6), stz_find_result_get(r, 2));
    try std.testing.expectEqual(@as(i64, 11), stz_find_result_get(r, 3));
    stz_find_result_free(r);
    str_free(s);
}

test "string count_of_ci" {
    const s = str_from("Hello hello HELLO hElLo", 23);
    try std.testing.expectEqual(@as(c_int, 4), str_count_of_cs(s, "hello", 5, 0));
    try std.testing.expectEqual(@as(c_int, 0), str_count_of_cs(s, "xyz", 3, 0));
    str_free(s);
}

test "string find_last_ci" {
    const s = str_from("abc-ABC-Abc", 11);
    try std.testing.expectEqual(@as(i64, 9), str_find_last_cs(s, "abc", 3, 0));
    try std.testing.expectEqual(@as(i64, -1), str_find_last_cs(s, "xyz", 3, 0));
    str_free(s);
}

test "string starts_with_ci" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_starts_with_cs(s, "hello", 5, 0));
    try std.testing.expectEqual(@as(c_int, 1), str_starts_with_cs(s, "HELLO", 5, 0));
    try std.testing.expectEqual(@as(c_int, 0), str_starts_with_cs(s, "world", 5, 0));
    str_free(s);
}

test "string ends_with_ci" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_ends_with_cs(s, "world", 5, 0));
    try std.testing.expectEqual(@as(c_int, 1), str_ends_with_cs(s, "WORLD", 5, 0));
    try std.testing.expectEqual(@as(c_int, 0), str_ends_with_cs(s, "hello", 5, 0));
    str_free(s);
}

test "string contains_ci" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_contains_cs(s, "WORLD", 5, 0));
    try std.testing.expectEqual(@as(c_int, 1), str_contains_cs(s, "hello", 5, 0));
    try std.testing.expectEqual(@as(c_int, 0), str_contains_cs(s, "xyz", 3, 0));
    str_free(s);
}

test "string split_count_ci" {
    const s = str_from("oneABCtwoabcthree", 17);
    try std.testing.expectEqual(@as(c_int, 3), str_split_count_cs(s, "abc", 3, 0));
    str_free(s);
}

test "string split_get_ci" {
    const s = str_from("oneABCtwoAbCthree", 17);
    const p0 = str_split_get_cs(s, "abc", 3, 1, 0);
    try std.testing.expect(mem.eql(u8, str_data(p0)[0..str_size(p0)], "one"));
    str_free(p0);
    const p1 = str_split_get_cs(s, "abc", 3, 2, 0);
    try std.testing.expect(mem.eql(u8, str_data(p1)[0..str_size(p1)], "two"));
    str_free(p1);
    const p2 = str_split_get_cs(s, "abc", 3, 3, 0);
    try std.testing.expect(mem.eql(u8, str_data(p2)[0..str_size(p2)], "three"));
    str_free(p2);
    str_free(s);
}

test "string replace_ci" {
    const s = str_from("Hello hello HELLO", 17);
    str_replace_cs(s, "hello", 5, "hi", 2, 0);
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
    try std.testing.expectEqual(@as(i64, 1), str_byte_to_cp(s, 1));
    try std.testing.expectEqual(@as(i64, 2), str_byte_to_cp(s, 2));
    try std.testing.expectEqual(@as(i64, 3), str_byte_to_cp(s, 3));
    try std.testing.expectEqual(@as(i64, 4), str_byte_to_cp(s, 4));
    str_free(s);
}

test "string replace_range" {
    const s = str_from("Hello World", 11);
    // Position 6 (1-based) = " ", replace 1 codepoint with "_beautiful_"
    const r = str_replace_range(s, 6, 1, "_beautiful_", 11);
    try std.testing.expectEqual(@as(usize, 21), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..21], "Hello_beautiful_World"));
    str_free(r);
    str_free(s);
}

test "string replace_range at edges" {
    const s = str_from("abc", 3);
    // Position 1 (1-based) = first codepoint
    const r1 = str_replace_range(s, 1, 1, "X", 1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..3], "Xbc"));
    str_free(r1);
    // Position 3 (1-based) = last codepoint
    const r2 = str_replace_range(s, 3, 1, "Z", 1);
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
    const p0 = str_split_get(s, "::", 2, 1);
    try std.testing.expect(mem.eql(u8, str_data(p0)[0..str_size(p0)], "one"));
    str_free(p0);
    const p1 = str_split_get(s, "::", 2, 2);
    try std.testing.expect(mem.eql(u8, str_data(p1)[0..str_size(p1)], "two"));
    str_free(p1);
    const p2 = str_split_get(s, "::", 2, 3);
    try std.testing.expect(mem.eql(u8, str_data(p2)[0..str_size(p2)], "three"));
    str_free(p2);
    str_free(s);
}

// ─── Unicode codepoint-position tests ───

test "find unicode codepoint positions" {
    // "bullet heart bullet bullet bullet bullet heart bullet bullet"
    // Each char is 3 bytes (U+2022=E2 80 A2, U+2665=E2 99 A5)
    // String: bullet(0) heart(1) bullet(2) bullet(3) bullet(4) bullet(5) heart(6) bullet(7) bullet(8)
    const str = "\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2\xe2\x80\xa2\xe2\x80\xa2\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2\xe2\x80\xa2";
    const s = str_from(str, 27);
    try std.testing.expectEqual(@as(usize, 9), str_count(s));

    // Find heart (E2 99 A5) -- should be at codepoint positions 2 and 7 (1-based)
    const r = str_find(s, "\xe2\x99\xa5", 3);
    try std.testing.expectEqual(@as(c_int, 2), stz_find_result_count(r));
    try std.testing.expectEqual(@as(i64, 2), stz_find_result_get(r, 1));
    try std.testing.expectEqual(@as(i64, 7), stz_find_result_get(r, 2));
    stz_find_result_free(r);

    // Find "bullet heart bullet" (9 bytes) -- at codepoint positions 1 and 6 (1-based)
    const sub = "\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2";
    const r2 = str_find(s, sub, 9);
    try std.testing.expectEqual(@as(c_int, 2), stz_find_result_count(r2));
    try std.testing.expectEqual(@as(i64, 1), stz_find_result_get(r2, 1));
    try std.testing.expectEqual(@as(i64, 6), stz_find_result_get(r2, 2));
    stz_find_result_free(r2);

    str_free(s);
}

test "find_first unicode codepoint position" {
    // "cafe" with e-acute: "caf\xC3\xA9X" -- 5 bytes, 4 codepoints + X
    const s = str_from("caf\xC3\xA9X", 6);
    try std.testing.expectEqual(@as(usize, 5), str_count(s));
    // 'X' is at byte 5 but codepoint position 5 (1-based)
    try std.testing.expectEqual(@as(i64, 5), str_find_first(s, "X", 1));
    str_free(s);
}

test "find_last unicode" {
    // Two hearts in multibyte string
    const str = "\xe2\x80\xa2\xe2\x99\xa5\xe2\x80\xa2\xe2\x99\xa5";
    const s = str_from(str, 12); // 4 chars, 12 bytes
    try std.testing.expectEqual(@as(usize, 4), str_count(s));
    // Last heart at codepoint position 4 (1-based)
    try std.testing.expectEqual(@as(i64, 4), str_find_last(s, "\xe2\x99\xa5", 3));
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

test "between: ALL semantics - single match" {
    const s = str_from("hello [world] end", 17);
    const r = str_between(s, "[", 1, "]", 1);
    try std.testing.expect(r != null);
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..5], "world"));
    str_free(r);
    str_free(s);
}

test "between: ALL semantics - multiple matches" {
    const s = str_from("[a][b][c]", 9);
    const r = str_between(s, "[", 1, "]", 1);
    try std.testing.expect(r != null);
    // "a\0b\0c" = 5 bytes
    try std.testing.expectEqual(@as(usize, 5), str_size(r));
    str_free(r);
    str_free(s);
}

test "between: ALL semantics - multi-char delimiters" {
    const s = str_from("start<<content>>end", 19);
    const r = str_between(s, "<<", 2, ">>", 2);
    try std.testing.expect(r != null);
    try std.testing.expectEqual(@as(usize, 7), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..7], "content"));
    str_free(r);
    str_free(s);
}

test "between: ALL semantics - not found returns empty" {
    const s = str_from("hello world", 11);
    const r = str_between(s, "[", 1, "]", 1);
    // ALL semantics returns empty handle (not null) when no match
    try std.testing.expect(r != null);
    try std.testing.expectEqual(@as(usize, 0), str_size(r));
    str_free(r);
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

test "remove" {
    const s = str_from("aXbXcXd", 7);
    const r = str_remove(s, "X", 1);
    try std.testing.expectEqual(@as(usize, 4), str_size(r));
    try std.testing.expect(mem.eql(u8, str_data(r)[0..4], "abcd"));
    str_free(r);
    str_free(s);
}

test "remove multi-byte" {
    // Remove heart from "a heart b heart c"
    const s = str_from("a\xe2\x99\xa5b\xe2\x99\xa5c", 9);
    const r = str_remove(s, "\xe2\x99\xa5", 3);
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
    try std.testing.expectEqual(@as(i64, 1), stz_find_result_get(r, 1)); // 'a'
    try std.testing.expectEqual(@as(i64, 3), stz_find_result_get(r, 2)); // 'b'
    try std.testing.expectEqual(@as(i64, 5), stz_find_result_get(r, 3)); // 'c'
    stz_find_result_free(r);
    str_free(s);
}

test "find_chars_of_type digits" {
    const s = str_from("a1b2c", 5);
    const r = str_find_chars_of_type(s, 1); // digits
    try std.testing.expectEqual(@as(c_int, 2), stz_find_result_count(r));
    try std.testing.expectEqual(@as(i64, 2), stz_find_result_get(r, 1)); // '1'
    try std.testing.expectEqual(@as(i64, 4), stz_find_result_get(r, 2)); // '2'
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

test "remove_ci" {
    const s = str_from("Hello HELLO hello", 17);
    const r = str_remove_cs(s, "hello", 5, 0);
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
    const l1 = str_line_at(s, 1);
    try std.testing.expect(mem.eql(u8, str_data(l1)[0..5], "line1"));
    str_free(l1);

    const l2 = str_line_at(s, 2);
    try std.testing.expect(mem.eql(u8, str_data(l2)[0..5], "line2"));
    str_free(l2);

    const l3 = str_line_at(s, 3);
    try std.testing.expect(mem.eql(u8, str_data(l3)[0..5], "line3"));
    str_free(l3);

    try std.testing.expect(str_line_at(s, 4) == null);
    str_free(s);

    // CRLF
    const s2 = str_from("a\r\nb\r\nc", 7);
    try std.testing.expectEqual(@as(c_int, 3), str_lines_split_count(s2));
    const la = str_line_at(s2, 1);
    try std.testing.expect(mem.eql(u8, str_data(la)[0..1], "a"));
    str_free(la);
    str_free(s2);
}

test "sort lines" {
    const s = str_from("cherry\napple\nbanana", 19) orelse return error.SkipZigTest;
    defer str_free(s);
    const sorted = str_sort_lines(s) orelse return error.SkipZigTest;
    defer str_free(sorted);
    try std.testing.expectEqualStrings("apple\nbanana\ncherry", sorted.slice());

    // Single line
    const s2 = str_from("hello", 5) orelse return error.SkipZigTest;
    defer str_free(s2);
    const sorted2 = str_sort_lines(s2) orelse return error.SkipZigTest;
    defer str_free(sorted2);
    try std.testing.expectEqualStrings("hello", sorted2.slice());

    // Empty
    const s3 = str_from("", 0) orelse return error.SkipZigTest;
    defer str_free(s3);
    const sorted3 = str_sort_lines(s3) orelse return error.SkipZigTest;
    defer str_free(sorted3);
    try std.testing.expectEqualStrings("", sorted3.slice());
}

test "unique lines" {
    const input = "apple\nbanana\napple\ncherry\nbanana";
    const s = str_from(input, input.len) orelse return error.SkipZigTest;
    defer str_free(s);
    const unique = str_unique_lines(s) orelse return error.SkipZigTest;
    defer str_free(unique);
    try std.testing.expectEqualStrings("apple\nbanana\ncherry", unique.slice());

    // All unique
    const s2 = str_from("a\nb\nc", 5) orelse return error.SkipZigTest;
    defer str_free(s2);
    const unique2 = str_unique_lines(s2) orelse return error.SkipZigTest;
    defer str_free(unique2);
    try std.testing.expectEqualStrings("a\nb\nc", unique2.slice());

    // All same
    const s3 = str_from("x\nx\nx", 5) orelse return error.SkipZigTest;
    defer str_free(s3);
    const unique3 = str_unique_lines(s3) orelse return error.SkipZigTest;
    defer str_free(unique3);
    try std.testing.expectEqualStrings("x", unique3.slice());
}

test "facade words_split" {
    const s = str_from("hello world  foo", 16) orelse return error.SkipZigTest;
    defer str_free(s);
    const ws = str_words_split(s) orelse return error.SkipZigTest;
    defer str_free(ws);
    try std.testing.expectEqualStrings("hello\x00world\x00foo", ws.slice());
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

// ─── CountLeadingChar / CountTrailingChar ───

// ─── IsNumericString: all digits, optional leading +/- ───

// ─── SpacifyChars: "abc" → "a b c" (codepoint-aware) ───

// ─── NumberOfBytesPerChar: returns list as "1 1 2 3" for mixed-byte chars ───

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

// ─── IsBinaryString: all chars are 0 or 1, optional 0b prefix ───

// ─── IsOctalString: all chars are 0-7, optional 0o prefix ───

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
    const w1 = str_word_at(s1, 1);
    try std.testing.expect(mem.eql(u8, str_data(w1)[0..@intCast(str_size(w1))], "hello"));
    str_free(w1);

    const w3 = str_word_at(s1, 3);
    try std.testing.expect(mem.eql(u8, str_data(w3)[0..@intCast(str_size(w3))], "foo"));
    str_free(w3);

    const w4 = str_word_at(s1, 4);
    try std.testing.expectEqual(@as(StzStringHandle, null), w4);
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

// ─── CountChar: count occurrences of a specific codepoint ───

// ─── Copy ───

// ─── IsCharsSortedAsc ───

// ─── IsCharsSortedDesc ───

// ─── RepeatChar ───

// ─── Truncate ───

// ─── WrapAt ───

// ─── EnsurePrefix ───

// ─── EnsureSuffix ───

// ─── CharFrequency ───
// Returns "char:count" pairs separated by newlines, e.g. "a:3\nb:2\n"

// ─── ContainsAnyOf ───
// Check if string contains any of the characters in the given string

// ─── ContainsAllOf ───

// ─── Only Letters / Digits ───

// (str_is_palindrome already defined above)

// ─── IsAlphanumeric ───

// (str_common_prefix already defined above)

// ─── CamelCase / SnakeCase / KebabCase ───

// ─── IsDigit (all chars are digits) ───

// ─── StringMultiply (interleave) ───

// Interleave: place separator between each codepoint. "abc" with "," => "a,b,c"

// ─── Surround ───

// Wrap string with prefix and suffix: surround("hello", "[", "]") => "[hello]"

// Rotate codepoints left by `n` positions. Negative n rotates right.
// Returns new handle with rotated string.

// Repeat string to fill exactly `target_len` codepoints.
// Returns new handle.

// Swap characters at two codepoint positions (1-based from host, converted to 0-based internally). Returns new handle.

// Reverse the order of words in the string. Words are whitespace-delimited.
// Returns new handle.

// Mask the string: replace middle characters with mask_char, keeping `keep` chars visible
// at start and end. E.g. mask("hello@mail.com", '*', 2) -> "he*********om"
// Returns new handle.

// Keep only ASCII vowels (a,e,i,o,u both cases). Returns new handle.

// Convert to URL-friendly slug: lowercase, spaces/underscores to hyphens,
// remove non-alphanumeric (except hyphens), collapse consecutive hyphens.
// Returns new handle.

// Split camelCase/PascalCase into space-separated words.
// E.g. "camelCaseString" -> "camel Case String"
// Returns new handle.

// Extract initials (first letter of each word). Words separated by spaces.
// E.g. "Hello World" -> "HW", "united states of america" -> "usoa"
// Returns new handle.

// Smart titlecase: capitalize words except small words (the, a, an, of, in, on, at, to, for, and, but, or, is).
// First word is always capitalized. Returns new handle.

// batch 7 ─────────────────────────────────────────────────────────

// batch 8 ─────────────────────────────────────────────────────────

// Mirror/reflect: "abc" -> "abccba"

// Repeat each character n times: "abc", 2 -> "aabbcc"

// batch 9 ─────────────────────────────────────────────────────────

// Sort words alphabetically (case-sensitive). Words separated by spaces.

// Keep only unique words (first occurrence preserved). Words separated by spaces.

// batch 10 ────────────────────────────────────────────────────────

// Run-length encode: "aaabbc" -> "3a2b1c"

// Run-length decode: "3a2b1c" -> "aaabbc"

// Return the most frequent character as a single-char string. Ties: first in byte order.

// batch 12 ────────────────────────────────────────────────────────

// Wrap string with prefix and suffix: wrap("hello", "[", "]") -> "[hello]"

// batch 13 ────────────────────────────────────────────────────────

// batch 14 ────────────────────────────────────────────────────────

// Abbreviate: produce a string of at most max_len total characters.
// If the string is longer, truncate to (max_len - 3) characters + "...".
// If max_len <= 3, just return "..." truncated to max_len.

// ─── Batch 15: left_pad, right_pad, is_numeric, is_alpha, is_alphanumeric ───

// ─── Batch 16: vigenere_encrypt, atbash, count_words_matching, truncate_words, to_constant_case ───

// ─── Batch 17: first_word, last_word, to_nato, commonality, diff_chars ───

// ─── Batch 18: rot47, is_isogram, reverse_each_word, count_digits, strip_tags ───

// ─── Batch 19: to_slug, count_spaces, normalize_spaces, mask_email, pluralize ───

// ─── Batch 20: deduplicate_lines, remove_blank_lines, extract_numbers, extract_emails, quote ───

// ─── Batch 21: number_lines, hide, extract_words ───

// ─── Batch 22: expand_tabs, sentence_count, chop, scan_int, to_ordinal ───

// batch 17 ─── NLP: Jaro-Winkler, Metaphone, N-grams ───

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

test "find_char" {
    const s1 = str_from("abcabc", 6);
    const fr = str_find_char(s1, 'a');
    try std.testing.expect(fr != null);
    try std.testing.expectEqual(@as(c_int, 2), stz_find_result_count(fr));
    try std.testing.expectEqual(@as(c_int, 1), stz_find_result_get(fr, 1));
    try std.testing.expectEqual(@as(c_int, 4), stz_find_result_get(fr, 2));
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

test "remove_first" {
    const s1 = str_from("hello world hello", 17);
    const r1 = str_remove_first(s1, "hello", 5);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], " world hello"));
    str_free(r1);
    str_free(s1);
}

test "remove_last" {
    const s1 = str_from("hello world hello", 17);
    const r1 = str_remove_last(s1, "hello", 5);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "hello world "));
    str_free(r1);
    str_free(s1);
}

test "remove_nth" {
    const s1 = str_from("abcabcabc", 9);
    const r0 = str_remove_nth(s1, "abc", 3, 0);
    try std.testing.expect(mem.eql(u8, str_data(r0)[0..@intCast(str_size(r0))], "abcabc"));
    str_free(r0);
    const r1 = str_remove_nth(s1, "abc", 3, 1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "abcabc"));
    str_free(r1);
    const r2 = str_remove_nth(s1, "abc", 3, 2);
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

test "insert_before_each_cs case-sensitive" {
    const s1 = str_from("AbcAbc", 6);
    const r1 = str_insert_before_each_cs(s1, "Abc", 3, "[", 1, 1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "[Abc[Abc"));
    str_free(r1);
    str_free(s1);
}

test "insert_before_each_cs case-insensitive" {
    const s1 = str_from("AbcABC", 6);
    const r1 = str_insert_before_each_cs(s1, "abc", 3, "[", 1, 0);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "[Abc[ABC"));
    str_free(r1);
    str_free(s1);
}

test "insert_after_each_cs case-sensitive" {
    const s1 = str_from("AbcAbc", 6);
    const r1 = str_insert_after_each_cs(s1, "Abc", 3, "]", 1, 1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "Abc]Abc]"));
    str_free(r1);
    str_free(s1);
}

test "insert_after_each_cs case-insensitive" {
    const s1 = str_from("AbcABC", 6);
    const r1 = str_insert_after_each_cs(s1, "abc", 3, "]", 1, 0);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "Abc]ABC]"));
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
    const w1 = str_nth_word(s1, 1);
    try std.testing.expect(mem.eql(u8, str_data(w1)[0..@intCast(str_size(w1))], "hello"));
    str_free(w1);

    const w2 = str_nth_word(s1, 2);
    try std.testing.expect(mem.eql(u8, str_data(w2)[0..@intCast(str_size(w2))], "world"));
    str_free(w2);

    const w3 = str_nth_word(s1, 3);
    try std.testing.expect(mem.eql(u8, str_data(w3)[0..@intCast(str_size(w3))], "foo"));
    str_free(w3);
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

test "remove_between: ALL semantics" {
    // Single pair
    const s1 = str_from("hello [world] end", 17);
    const r1 = str_remove_between(s1, "[", 1, "]", 1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "hello  end"));
    str_free(r1);
    str_free(s1);

    // Multiple pairs — ALL semantics removes all
    const s2 = str_from("a[x]b[y]c", 9);
    const r2 = str_remove_between(s2, "[", 1, "]", 1);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "abc"));
    str_free(r2);
    str_free(s2);

    // HTML tags
    const s3 = str_from("before<tag>inside</tag>after", 28);
    const r3 = str_remove_between(s3, "<tag>", 5, "</tag>", 6);
    try std.testing.expect(mem.eql(u8, str_data(r3)[0..@intCast(str_size(r3))], "beforeafter"));
    str_free(r3);
    str_free(s3);
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

test "replace_between: ALL semantics" {
    // Single pair
    const s1 = str_from("hello [world] end", 17);
    const r1 = str_replace_between(s1, "[", 1, "]", 1, "REPLACED", 8);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "hello REPLACED end"));
    str_free(r1);
    str_free(s1);

    // Multiple pairs — ALL semantics replaces all
    const s2 = str_from("a[x]b[y]c[z]d", 13);
    const r2 = str_replace_between(s2, "[", 1, "]", 1, "!", 1);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "a!b!c!d"));
    str_free(r2);
    str_free(s2);

    // Replace with empty
    const s3 = str_from("a<b>c", 5);
    const r3 = str_replace_between(s3, "<", 1, ">", 1, "", 0);
    try std.testing.expect(mem.eql(u8, str_data(r3)[0..@intCast(str_size(r3))], "ac"));
    str_free(r3);
    str_free(s3);
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
    const r = str_ngram(h, 2, 1);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "he"));
    str_free(r);

    const r2 = str_ngram(h, 2, 4);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "lo"));
    str_free(r2);

    const r3 = str_ngram(h, 2, 5);
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
    const r1 = str_chunk(h, 3, 1);
    try std.testing.expect(mem.eql(u8, str_data(r1)[0..@intCast(str_size(r1))], "abc"));
    str_free(r1);

    const r2 = str_chunk(h, 3, 2);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "def"));
    str_free(r2);

    const r3 = str_chunk(h, 3, 3);
    try std.testing.expect(mem.eql(u8, str_data(r3)[0..@intCast(str_size(r3))], "gh"));
    str_free(r3);

    const r4 = str_chunk(h, 3, 4);
    try std.testing.expectEqual(@as(StzStringHandle, null), r4);
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
    const r = str_swap_words(h, 1, 3);
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
    const r = str_remove_nth_word(h, 2);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "hello foo"));
    str_free(r);
    str_free(h);

    const h2 = str_from("hello world foo", 15);
    const r2 = str_remove_nth_word(h2, 1);
    try std.testing.expect(mem.eql(u8, str_data(r2)[0..@intCast(str_size(r2))], "world foo"));
    str_free(r2);
    str_free(h2);
}

test "insert_word_at" {
    const h = str_from("hello foo", 9);
    const r = str_insert_word_at(h, 2, "world", 5);
    try std.testing.expect(mem.eql(u8, str_data(r)[0..@intCast(str_size(r))], "hello world foo"));
    str_free(r);
    str_free(h);

    const h2 = str_from("world foo", 9);
    const r2 = str_insert_word_at(h2, 1, "hello", 5);
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
    try std.testing.expectEqual(@as(c_int, 1), str_equals_cs(a, b, 0));
    str_free(a);
    str_free(b);

    // French accented: "cafe" vs "CAFE" (basic)
    const c = str_from("caf\xC3\xA9", 5);
    const d = str_from("CAF\xC3\x89", 5);
    try std.testing.expectEqual(@as(c_int, 1), str_equals_cs(c, d, 0));
    str_free(c);
    str_free(d);
}

test "contains_ci unicode" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_contains_cs(s, "WORLD", 5, 0));
    try std.testing.expectEqual(@as(c_int, 1), str_contains_cs(s, "hello", 5, 0));
    try std.testing.expectEqual(@as(c_int, 0), str_contains_cs(s, "xyz", 3, 0));
    str_free(s);
}

test "starts_with_ci unicode" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_starts_with_cs(s, "HELLO", 5, 0));
    try std.testing.expectEqual(@as(c_int, 1), str_starts_with_cs(s, "hello", 5, 0));
    try std.testing.expectEqual(@as(c_int, 0), str_starts_with_cs(s, "world", 5, 0));
    str_free(s);
}

test "ends_with_ci unicode" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(c_int, 1), str_ends_with_cs(s, "WORLD", 5, 0));
    try std.testing.expectEqual(@as(c_int, 1), str_ends_with_cs(s, "world", 5, 0));
    try std.testing.expectEqual(@as(c_int, 0), str_ends_with_cs(s, "hello", 5, 0));
    str_free(s);
}

test "find_ci unicode" {
    const s = str_from("abcABCabc", 9);
    const r = str_find_cs(s, "abc", 3, 0);
    try std.testing.expectEqual(@as(c_int, 3), stz_find_result_count(r));
    try std.testing.expectEqual(@as(i64, 1), stz_find_result_get(r, 1));
    try std.testing.expectEqual(@as(i64, 4), stz_find_result_get(r, 2));
    try std.testing.expectEqual(@as(i64, 7), stz_find_result_get(r, 3));
    stz_find_result_free(r);
    str_free(s);
}

test "count_of_ci unicode" {
    const s = str_from("abcABCabc", 9);
    try std.testing.expectEqual(@as(c_int, 3), str_count_of_cs(s, "abc", 3, 0));
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

test "find_first_cs case sensitive" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(i64, 7), str_find_first_cs(s, "World", 5, 1));
    try std.testing.expectEqual(@as(i64, -1), str_find_first_cs(s, "world", 5, 1));
    str_free(s);
}

test "find_first_cs case insensitive" {
    const s = str_from("Hello World", 11);
    try std.testing.expectEqual(@as(i64, 7), str_find_first_cs(s, "WORLD", 5, 0));
    try std.testing.expectEqual(@as(i64, 1), str_find_first_cs(s, "hello", 5, 0));
    str_free(s);
}

test "find_cs" {
    const s = str_from("abcABCabc", 9);
    const r1 = str_find_cs(s, "abc", 3, 1);
    try std.testing.expectEqual(@as(c_int, 2), stz_find_result_count(r1));
    stz_find_result_free(r1);
    const r0 = str_find_cs(s, "abc", 3, 0);
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

test "find_last_cs" {
    const s = str_from("abcABCabc", 9);
    try std.testing.expectEqual(@as(i64, 7), str_find_last_cs(s, "abc", 3, 1));
    try std.testing.expectEqual(@as(i64, 7), str_find_last_cs(s, "abc", 3, 0)); // last CI match at pos 7
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

test "find_first uses BMH for long ASCII needles" {
    // Needle > 4 bytes, ASCII string -- should use BMH path
    const s = str_from("The quick brown fox jumps over the lazy dog", 43);
    try std.testing.expectEqual(@as(i64, 17), str_find_first(s, "fox j", 5)); // 1-based
    try std.testing.expectEqual(@as(i64, 32), str_find_first(s, "the lazy", 8)); // 1-based
    try std.testing.expectEqual(@as(i64, -1), str_find_first(s, "cat jumps", 9));
    str_free(s);
}

test "cpCount ASCII fast-path" {
    // ASCII: codepoint count == byte count
    const s = str_from("Hello World!", 12);
    try std.testing.expectEqual(@as(usize, 12), str_count(s));
    str_free(s);
}

test "duplicate_substrings_cs basic" {
    const s = str_from("abab", 4);
    defer str_free(s);
    const r = str_duplicate_substrings_cs(s, 1);
    defer str_free(r);
    try std.testing.expect(r != null);
    // Should contain at least "a", "b", "ab"
    const result = r.?.slice();
    try std.testing.expect(result.len > 0);
    // Count null-separated items
    var count: usize = 1;
    for (result) |c| {
        if (c == 0) count += 1;
    }
    try std.testing.expect(count >= 3); // at least a, b, ab
}

test "duplicate_substrings_cs no duplicates" {
    const s = str_from("abcd", 4);
    defer str_free(s);
    const r = str_duplicate_substrings_cs(s, 1);
    defer str_free(r);
    try std.testing.expect(r != null);
    try std.testing.expectEqual(@as(usize, 0), r.?.slice().len);
}

test "duplicate_substrings_cs case-insensitive" {
    const s = str_from("AbAb", 4);
    defer str_free(s);
    // Case-sensitive: "A" appears twice (pos 1,3), "b" appears twice (pos 2,4)
    // but "a" appears 0 times
    const r_cs = str_duplicate_substrings_cs(s, 1);
    defer str_free(r_cs);
    // Case-insensitive: "a/A" appears 4 times conceptually
    const r_ci = str_duplicate_substrings_cs(s, 0);
    defer str_free(r_ci);
    try std.testing.expect(r_ci != null);
    try std.testing.expect(r_ci.?.slice().len > 0);
}

test "unique_lines_cs case-sensitive" {
    const input = "Hello\nhello\nWorld\nHELLO\nworld";
    const s = str_from(input, input.len);
    const r = str_unique_lines_cs(s, 1);
    try std.testing.expect(r != null);
    // All 5 lines are distinct case-sensitively
    try std.testing.expectEqualStrings("Hello\nhello\nWorld\nHELLO\nworld", r.?.slice());
    str_free(r);
    str_free(s);
}

test "unique_lines_cs case-insensitive" {
    const input = "Hello\nhello\nWorld\nHELLO\nworld";
    const s = str_from(input, input.len);
    const r = str_unique_lines_cs(s, 0);
    try std.testing.expect(r != null);
    try std.testing.expectEqualStrings("Hello\nWorld", r.?.slice());
    str_free(r);
    str_free(s);
}

test "unique_lines_cs CI preserves first case" {
    const input = "ABC\nabc\nDef\ndef\nDEF";
    const s = str_from(input, input.len);
    const r = str_unique_lines_cs(s, 0);
    try std.testing.expect(r != null);
    try std.testing.expectEqualStrings("ABC\nDef", r.?.slice());
    str_free(r);
    str_free(s);
}

test "reverse_lines" {
    const input = "first\nsecond\nthird";
    const s = str_from(input, input.len);
    const r = str_reverse_lines(s);
    try std.testing.expect(r != null);
    try std.testing.expectEqualStrings("third\nsecond\nfirst", r.?.slice());
    str_free(r);
    str_free(s);
}

test "reverse_lines single" {
    const s = str_from("only", 4);
    const r = str_reverse_lines(s);
    try std.testing.expect(r != null);
    try std.testing.expectEqualStrings("only", r.?.slice());
    str_free(r);
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

