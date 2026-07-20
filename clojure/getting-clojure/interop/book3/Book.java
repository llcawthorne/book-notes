/***
 * Excerpted from "Getting Clojure",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
***/
public class Book {

    // Make the fields private, accessible only inside this class.

    private String title;
    private String author;
    private int numberChapters;

    public Book(String t, String a, int nChaps) {
        title = t;
        author = a;
        numberChapters = nChaps;
    }

    // Add getter methods to make fields available to the outside world.

    public String getTitle() {
        return title;
    }

    public String getAuthor() {
        return author;
    }

    public int getNumberChapters() {
        return numberChapters;
    }
}
