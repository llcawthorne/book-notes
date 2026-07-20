/***
 * Excerpted from "Getting Clojure",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
***/
package com.russolsen.blottsbooks;


// By default, Publication is a subclass of java.lang.Object.

public class Publication {
    private String title;
    private String author;

    public Publication(String t, String a) {
        title = t;
        author = a;
    }
    public String getTitle() {
        return title;
    }
    public String getAuthor() {
        return author;
    }
}

