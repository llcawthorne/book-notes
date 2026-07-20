/***
 * Excerpted from "Getting Clojure",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
***/
package com.russolsen.blottsbooks;

// Book is now a subclass of Publication, which handles the author and title.

public class Book extends Publication {
    private int numberChapters;

    public Book(String t, String a, int nChaps) {
          super(t, a);
          numberChapters = nChaps;
    }

    public int getNumberChapters() {
        return numberChapters;
    }
}
