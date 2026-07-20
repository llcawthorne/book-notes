/***
 * Excerpted from "Getting Clojure",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
***/
public class Book {

    //Note the fields are public.

    public String title;
    public String author;
    public int numberChapters;

    public Book(String t, String a, int nChaps) {
        title = t;
        author = a;
        numberChapters = nChaps;
    }

    public void publish() {
        // Do something to publish the book.
    }

    public void payRoyalties() {
        // Do something to pay royalties.
    }
}
