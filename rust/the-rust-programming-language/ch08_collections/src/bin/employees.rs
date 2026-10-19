use std::collections::HashMap;
use std::io;

fn main() {
    let mut company: HashMap<String, Vec<String>> = HashMap::new();

    println!("Commands: Add <name> to <department>, List <department>,");
    println!("          List all, Quit");

    loop {
        let mut input = String::new();
        io::stdin()
            .read_line(&mut input)
            .expect("Failed to read line");

        let mut words = Vec::new();
        for word in input.split_whitespace() {
            words.push(word);
        }

        if words.is_empty() || words[0] == "Quit" {
            break;
        } else if words[0] == "Add" && words.len() >= 4 && words[2] == "to" {
            add_employee(&mut company, words[1], &words[3..].join(" "));
        } else if words[0] == "List" && words.len() == 2 && words[1] == "all" {
            list_all(&company);
        } else if words[0] == "List" && words.len() >= 2 {
            list_department(&company, &words[1..].join(" "));
        } else {
            println!("Sorry, I didn't understand that.");
        }
    }
}

fn add_employee(company: &mut HashMap<String, Vec<String>>, name: &str, dept: &str) {
    let people = company.entry(dept.to_string()).or_default();
    people.push(name.to_string());
    println!("Added {name} to {dept}.");
}

fn list_department(company: &HashMap<String, Vec<String>>, dept: &str) {
    match company.get(dept) {
        Some(people) => {
            let mut people = people.clone();
            people.sort();
            println!("{dept}:");
            for person in &people {
                println!("  {person}");
            }
        }
        None => println!("No department named {dept}."),
    }
}

fn list_all(company: &HashMap<String, Vec<String>>) {
    let mut depts = Vec::new();
    for dept in company.keys() {
        depts.push(dept);
    }
    depts.sort();
    for dept in depts {
        list_department(company, dept);
    }
}
