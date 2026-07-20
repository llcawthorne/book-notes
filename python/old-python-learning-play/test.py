#!/usr/bin/env python  
out_file = open("person.txt", "w")
out_file.close()

while True:
    name = raw_input("what is the name ")
    age = raw_input("what is the age ")

    if name == "exit":
        break

    out_file = open("persons.txt", "a")
    out_file.write("name: ")
    out_file.write(name)
    out_file.write("\n")
    out_file.write("age: ")
    out_file.write(age)
    out_file.write("\n")
    out_file.write("\n")
    out_file.close()
