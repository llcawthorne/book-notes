use std::collections::HashMap;

fn main() {
    let v = vec![1, 2, 3, 4, 5, 5, 5];
    println!(
        "The median is {}",
        median(&v).expect("No median of an empty list!")
    );
    println!(
        "The mode is {}",
        mode(&v).expect("No mode of an empty list!")
    );
}

fn median(v: &[i32]) -> Option<f64> {
    if v.is_empty() {
        return None;
    }
    let mut v = v.to_vec();
    v.sort();
    let l = v.len();
    if l.is_multiple_of(2) {
        Some((v[l / 2 - 1] as f64 + v[l / 2] as f64) / 2.0)
    } else {
        Some(v[l / 2] as f64)
    }
}

fn mode(v: &[i32]) -> Option<i32> {
    if v.is_empty() {
        return None;
    }
    let mut counts = HashMap::new();
    for &item in v {
        *counts.entry(item).or_insert(0) += 1;
    }
    let mut mode = v[0];
    let mut mode_count = 0;
    for (&item, &count) in &counts {
        if count > mode_count || (count == mode_count && item < mode) {
            mode_count = count;
            mode = item;
        }
    }
    Some(mode)
}
