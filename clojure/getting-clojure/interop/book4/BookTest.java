/***
 * Excerpted from "Getting Clojure",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
***/
package com.russolsen.blottsbooks;

public class BookTest {

  public static void main(String[] args) {
    Book b = new Book("Emma", "Austen", 10);
    assert b instanceof Book;
    assert b instanceof Publication;


    assert b.getAuthor() == "Austen";
    assert b.getTitle() == "Emma";
    assert b.getNumberChapters() ==  10;
    }
}
