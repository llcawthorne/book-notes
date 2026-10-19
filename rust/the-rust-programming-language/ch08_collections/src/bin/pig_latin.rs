fn main() {
    let sample_string = String::from("This is a test of the pig latin system!");
    println!("{}", pig_latinize(&sample_string));
}

fn pig_latinize(s: &str) -> String {
    let mut new_words = Vec::new();
    let mut word_count = 0;
    let l = s.split_whitespace().count();
    for word in s.split_whitespace() {
        let mut new_word = String::new();
        let mut first_letter = ' ';
        let mut punctuation = ' ';
        word_count += 1;
        for (i, c) in word.to_lowercase().chars().enumerate() {
            if i == 0 {
                first_letter = c;
            } else {
                if !c.is_ascii_punctuation() {
                    new_word.push(c);
                } else {
                    punctuation = c;
                }
                if i == word.chars().count() - 1 {
                    new_word.push('-');
                    new_word.push(first_letter);
                    new_word.push_str("ay");
                    if word_count == l && punctuation != ' ' {
                        new_word.push(punctuation);
                    }
                }
            }
            if "aeiouAEIOU".contains(first_letter) {
                new_word.push_str(word);
                new_word.push_str("-hay");
                break;
            }
        }
        new_words.push(new_word);
    }
    capitalize_first(&new_words.join(" "))
}

fn capitalize_first(s: &str) -> String {
    let mut new_string = String::new();
    for (i, c) in s.char_indices() {
        if i == 0 {
            new_string.push(c.to_ascii_uppercase());
        } else {
            new_string.push(c);
        }
    }
    new_string
}
