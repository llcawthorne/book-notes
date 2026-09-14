# Django 5 by Example

## Chapter 1 - Building a Blog Application

- Django follows the MTV (Model-Template-View) pattern. It is similar to MVC
  where the template acts as the view and the framework itself acts as the
  controller.

  - Model: This defines the logical structure and is the data handler between
    the database and the view.
  - Template: This is the presentation layer. Django uses a plain-text template
    system that keeps everything that the browser renders.
  - View: This communicates with the database via the models and transfers the
    data to the template for viewing.

- The framework itself acts as the controller. It sends a request to the
  appropriate view according to the Django URL configuration.
- (AI Comment) Django's MVT is still MVC underneath: what Rails calls a
  controller, Django calls a view (a function/class that takes a request, talks
  to models, picks what to render, returns a response). What Rails calls a
  view (the ERB template), Django calls a template. Django just uses "view"
  for "the thing that decides what to show" rather than "the visual output,"
  which is the opposite of how Rails uses the word.
- This is how Django handles HTTP requests and generates responses:
  1. A web browser requests a page by its URL and the web server passes the HTTP
     request to Django.
  2. Django runs through its configured URL patterns and stops at the first
     one that matches the requested URL.
  3. Django executes the view that corresponds to the matched URL pattern.
  4. The view potentially uses data models to retrieve information from the
     database.
  5. Data models provie data definitions and behaviors. They are used to query
     the database.
  6. The view renders a template (usually HTML) to display the data and returns
     it with an HTTP response.
- You can create a new project with `django-admin startproject mysite`.
- To apply migrations run 'python manage.py migrate' from the base directory.
