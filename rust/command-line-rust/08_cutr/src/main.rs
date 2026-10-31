use anyhow::{Result, anyhow, bail};
use clap::Parser;
use csv::{ReaderBuilder, StringRecord};
use regex::Regex;
use std::{
    fs::File,
    io::{self, BufRead, BufReader},
    num::NonZeroUsize,
    ops::Range,
};

#[derive(Debug, Parser)]
#[command(author, version, about)]
/// Rust version of `cut`
struct Args {
    /// Input file(s)
    #[arg(default_value = "-")]
    files: Vec<String>,

    /// Field delimiter
    #[arg(short, long, value_name = "DELIMITER", default_value = "\t")]
    delimiter: String,

    #[command(flatten)]
    extract: ArgsExtract,
}

#[derive(Debug, clap::Args)]
#[group(required = true, multiple = false)]
struct ArgsExtract {
    // Selected fields
    #[arg(short, long, value_name = "FIELDS")]
    fields: Option<String>,

    // Selected bytes
    #[arg(short, long, value_name = "BYTES")]
    bytes: Option<String>,

    // Selected chars
    #[arg(short, long, value_name = "CHARS")]
    chars: Option<String>,
}

type PositionList = Vec<Range<usize>>;

#[derive(Debug)]
pub enum Extract {
    Fields(PositionList),
    Bytes(PositionList),
    Chars(PositionList),
}

fn parse_pos(range: String) -> Result<PositionList> {
    let range_re = Regex::new(r"^(\d+)-(\d+)$").unwrap();
    range
        .split(',')
        .into_iter()
        .map(|val| {
            parse_index(val).map(|n| n..n + 1).or_else(|e| {
                range_re.captures(val).ok_or(e).and_then(|captures| {
                    let n1 = parse_index(&captures[1])?;
                    let n2 = parse_index(&captures[2])?;
                    if n1 >= n2 {
                        bail!(
                            "First number in range ({}) \
                            must be lower than second number ({})",
                            n1 + 1,
                            n2 + 1
                        );
                    }
                    Ok(n1..n2 + 1)
                })
            })
        })
        .collect::<Result<_, _>>()
        .map_err(From::from)
}

fn parse_index(input: &str) -> Result<usize> {
    let value_error = || anyhow!(r#"illegal list value: "{input}""#);
    input
        .starts_with('+')
        .then(|| Err(value_error()))
        .unwrap_or_else(|| {
            input
                .parse::<NonZeroUsize>()
                .map(|n| usize::from(n) - 1)
                .map_err(|_| value_error())
        })
}

fn main() {
    if let Err(e) = run(Args::parse()) {
        eprintln!("{e}");
        std::process::exit(1);
    }
}

fn run(args: Args) -> Result<()> {
    let delim_bytes = args.delimiter.as_bytes();
    if delim_bytes.len() != 1 {
        bail!(r#"--delim "{}" must be a single byte"#, args.delimiter);
    }
    let delimiter: u8 = *delim_bytes.first().unwrap();
    println!("{delimiter}");

    let extract = if let Some(fields) = args.extract.fields.map(parse_pos).transpose()? {
        Extract::Fields(fields)
    } else if let Some(bytes) = args.extract.bytes.map(parse_pos).transpose()? {
        Extract::Bytes(bytes)
    } else if let Some(chars) = args.extract.chars.map(parse_pos).transpose()? {
        Extract::Chars(chars)
    } else {
        unreachable!("Must have --fields, --bytes, or --chars");
    };

    println!("{extract:?}");

    for filename in &args.files {
        match open(filename) {
            Err(err) => eprintln!("{filename}: {err}"),
            Ok(_) => println!("Opened {filename}"),
        }
    }

    Ok(())
}

fn open(filename: &str) -> Result<Box<dyn BufRead>> {
    match filename {
        "-" => Ok(Box::new(BufReader::new(io::stdin()))),
        _ => Ok(Box::new(BufReader::new(File::open(filename)?))),
    }
}

fn extract_chars(line: &str, char_pos: &[Range<usize>]) -> String {
    let chars: Vec<_> = line.chars().collect();
    let mut selected: Vec<char> = vec![];

    for range in char_pos.iter().cloned() {
        for i in range {
            if let Some(val) = chars.get(i) {
                selected.push(*val)
            }
        }
    }
    selected.iter().collect()
}

fn extract_bytes(line: &str, byte_pos: &[Range<usize>]) -> String {
    unimplemented!();
}

fn extract_fields(record: &StringRecord, field_pos: &[Range<usize>]) -> Vec<String> {
    unimplemented!();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_pos_empty() {
        assert!(parse_pos("".to_string()).is_err());
    }

    #[test]
    fn parse_pos_zero() {
        let res = parse_pos("0".to_string());
        assert!(res.is_err());
        assert_eq!(res.unwrap_err().to_string(), r#"illegal list value: "0""#);

        let res = parse_pos("0-1".to_string());
        assert!(res.is_err());
        assert_eq!(res.unwrap_err().to_string(), r#"illegal list value: "0""#);
    }

    #[test]
    fn parse_pos_leading_plus() {
        for val in ["+1", "+1-2", "1-+2"] {
            let res = parse_pos(val.to_string());
            assert!(res.is_err());
            assert_eq!(
                res.unwrap_err().to_string(),
                format!(r#"illegal list value: "{val}""#)
            );
        }
    }

    #[test]
    fn parse_pos_non_numeric() {
        assert_eq!(
            parse_pos("a".to_string()).unwrap_err().to_string(),
            r#"illegal list value: "a""#
        );
        assert_eq!(
            parse_pos("1,a".to_string()).unwrap_err().to_string(),
            r#"illegal list value: "a""#
        );
        assert_eq!(
            parse_pos("1-a".to_string()).unwrap_err().to_string(),
            r#"illegal list value: "1-a""#
        );
        assert_eq!(
            parse_pos("a-1".to_string()).unwrap_err().to_string(),
            r#"illegal list value: "a-1""#
        );
    }

    #[test]
    fn parse_pos_malformed_ranges() {
        for val in ["-", ",", "1,", "1-", "1-1-1", "1-1-a"] {
            assert!(parse_pos(val.to_string()).is_err());
        }
    }

    #[test]
    fn parse_pos_descending_range() {
        let res = parse_pos("1-1".to_string());
        assert!(res.is_err());
        assert_eq!(
            res.unwrap_err().to_string(),
            "First number in range (1) must be lower than second number (1)"
        );

        let res = parse_pos("2-1".to_string());
        assert!(res.is_err());
        assert_eq!(
            res.unwrap_err().to_string(),
            "First number in range (2) must be lower than second number (1)"
        );
    }

    #[test]
    fn parse_pos_valid() {
        assert_eq!(parse_pos("1".to_string()).unwrap(), vec![0..1]);
        assert_eq!(parse_pos("01".to_string()).unwrap(), vec![0..1]);
        assert_eq!(parse_pos("1,3".to_string()).unwrap(), vec![0..1, 2..3]);
        assert_eq!(parse_pos("001,0003".to_string()).unwrap(), vec![0..1, 2..3]);
        assert_eq!(parse_pos("1-3".to_string()).unwrap(), vec![0..3]);
        assert_eq!(parse_pos("0001-03".to_string()).unwrap(), vec![0..3]);
        assert_eq!(
            parse_pos("1,7,3-5".to_string()).unwrap(),
            vec![0..1, 6..7, 2..5]
        );
        assert_eq!(
            parse_pos("15,19-20".to_string()).unwrap(),
            vec![14..15, 18..20]
        );
    }

    #[test]
    fn test_extract_chars() {
        assert_eq!(extract_chars("", &[0..1]), "".to_string());
        assert_eq!(extract_chars("ábc", &[0..1]), "á".to_string());
        assert_eq!(extract_chars("ábc", &[0..1, 2..3]), "ác".to_string());
        assert_eq!(extract_chars("ábc", &[0..3]), "ábc".to_string());
        assert_eq!(extract_chars("ábc", &[2..3, 1..2]), "cb".to_string());
        assert_eq!(extract_chars("ábc", &[0..1, 1..2, 4..5]), "áb".to_string());
    }

    #[test]
    fn test_extract_bytes() {
        assert_eq!(extract_bytes("ábc", &[0..1]), "�".to_string());
        assert_eq!(extract_bytes("ábc", &[0..2]), "á".to_string());
        assert_eq!(extract_bytes("ábc", &[0..3]), "áb".to_string());
        assert_eq!(extract_bytes("ábc", &[0..4]), "ábc".to_string());
        assert_eq!(extract_bytes("ábc", &[3..4, 2..3]), "cb".to_string());
        assert_eq!(extract_bytes("ábc", &[0..2, 5..6]), "á".to_string());
    }

    #[test]
    fn test_extract_fields() {
        let rec = StringRecord::from(vec!["Captain", "Sham", "12345"]);
        assert_eq!(extract_fields(&rec, &[0..1]), &["Captain"]);
        assert_eq!(extract_fields(&rec, &[1..2]), &["Sham"]);
        assert_eq!(extract_fields(&rec, &[0..1, 2..3]), &["Captain", "12345"]);
        assert_eq!(extract_fields(&rec, &[0..1, 3..4]), &["Captain"]);
        assert_eq!(extract_fields(&rec, &[1..2, 0..1]), &["Sham", "Captain"]);
    }
}
