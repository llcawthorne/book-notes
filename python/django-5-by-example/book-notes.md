# Django 5 by Example

## Chapter 1 - Building a Blog Application

- Django follows the MTV (Model-Template-View) pattern, its own take on MVC.
  Django's "View" is confusingly named: it plays the role of MVC's Controller
  (it takes a request, talks to models, decides what to render, and returns a
  response), not MVC's View. Django's "Template" plays the role of MVC's View
  (the presentation layer). The remaining piece of MVC's Controller job,
  deciding *which* view handles a request, is handled by the framework's URL
  dispatcher rather than by application code you write.

  - Model: This defines the logical structure and is the data handler between
    the database and the view.
  - Template: This is the presentation layer. Django uses a plain-text template
    system that keeps everything that the browser renders.
  - View: This communicates with the database via the models and transfers the
    data to the template for viewing. This is Django's equivalent of MVC's
    Controller, not MVC's View.

- The framework itself sends a request to the appropriate view according to
  the Django URL configuration.
- This is how Django handles HTTP requests and generates responses:
  1. A web browser requests a page by its URL and the web server passes the HTTP
     request to Django.
  2. Django runs through its configured URL patterns and stops at the first
     one that matches the requested URL.
  3. Django executes the view that corresponds to the matched URL pattern.
  4. The view potentially uses data models to retrieve information from the
     database.
  5. Data models provide data definitions and behaviors. They are used to
     query the database.
  6. The view renders a template (usually HTML) to display the data and returns
     it with an HTTP response.
- You can create a new project with `django-admin startproject mysite`.
- To apply migrations run 'python manage.py migrate' from the base directory.
- A new project already has initial migrations to apply.
- Start a dev server with `python manage.py runserver`.
- In Django, a *project* is considered a Django installation with some settings.
  An *application* is a group of models, views, templates, and URLs. Think of
  a project as your website which contains several applications such as a blog,
  wiki, or forum. Applications can be re-used in other Django projects.
- To create an application you can run `python manage.py startapp blog`.
- You put models in an `app/models.py` file, where `app` is the application name.

  ```py
  # blog/models.py
  from django.conf import settings
  from django.db import models
  from django.utils import timezone

  class Post(models.Model):
      class Status(models.TextChoices):
          DRAFT = 'DF', 'Draft'
          PUBLISHED = 'PB', 'Published'
      title = models.CharField(max_length=250)
      slug = models.SlugField(max_length=250)
      author = models.ForeignKey(
          settings.AUTH_USER_MODEL,
          on_delete=models.CASCADE,
          related_name='blog_posts'
      )
      body = models.TextField()
      publish = models.DateTimeField(default=timezone.now)
      created = models.DateTimeField(auto_now_add=True)
      updated = models.DateTimeField(auto_now=True)
      status = models.CharField(
          max_length=2,
          choices=Status,
          default=Status.DRAFT
      )

      class Meta:
          ordering = ['-publish']
          indexes = [
              models.Index(fields=['-publish']),
          ]

      def __str__(self):
          return self.title
  ```

- You can define a model field as primary key by setting `primary_key=True` on
  it. Otherwise, Django generates an `id` field that defaults to `BigAutoField`.
- `auto_now_add` and `auto_now` are useful with `DateTimeField`s for tracking
  the creation and last modification time of objects.
- A `Meta` class within a model class defines metadata for the model. Here we
  use `ordering` to tell Django to order Posts by the `publish` field. The `-`
  indicates descending order. Also in the `Meta` class we define an index on
  the `publish` field.
- We define a many-to-one relationship between `auth.User`, the default
  `AUTH_USER_MODEL` value, and our `Post` class. A User can have many Posts.
- We need to activate the `blog` application so Django is aware of it and can
  create database tables for its models. You do this by editing
  `mysite/settings.py` and adding `blog.apps.BlogConfig` to `INSTALLED_APPS`.
- Running `python manage.py shell` will open a shell for you to interact with
  your Django code. We could `from blog.models import Post` and look at
  `Post.Status.choices` to see our `enum` choices as value-label pairs.
- Running `python manage.py makemigrations blog` will generate migrations for
  our application. `python manage.py sqlmigrate blog 0001` will show the sql for
  the new migration. `python manage.py migrate` applies migrations for all apps
  listed in `INSTALLED_APPS`. If you make changes in `models.py` that add,
  remove, or change fields of existing models or add new models, you'll need
  to run `makemigrations` and `migrate` again.
- To use the admin pages, you need to create a superuser with
  `python manage.py createsuperuser`. To add our Posts model to the admin page,
  we need to edit `admin.py` and add `from .models import Post` and 
  `admin.site.register(Post)`.
- You can see the [full documentation for the admin site](https://docs.djangoproject.com/en/5.0/ref/contrib/admin/), but we're going to set some options we like
  for our post model:

  ```py
  # mysite/blog/admin.py
  from django.contrib import admin

  from .models import Post


  @admin.register(Post)
  class PostAdmin(admin.ModelAdmin):
      list_display = ["title", "slug", "author", "publish", "status"]
      list_filter = ["status", "created", "publish", "author"]
      search_fields = ["title", "body"]
      prepopulated_fields = {"slug": ("title",)}
      raw_id_fields = ["author"]
      date_hierarchy = "publish"
      ordering = ["status", "publish"]
      show_facets = admin.ShowFacets.ALWAYS
  ```

- The Django ORM is based on QuerySets. A QuerySet is a collection of database
  queries to retrieve objects from your database. The QuerySet equates to a
  `SELECT` SQL statement and the filters are limiting SQL clauses such as
  `WHERE` and `LIMIT`.
- You can open an interactive shell with `python manage.py shell`.

  ```py
  >>> from blog.models import Post
  >>> user = User.objects.get(username='admin')
  >>> post = Post(title='Another post',
  ...             slug='another-post',
  ...             body='Post body.',
  ...             author=user)
  >>> post.save()
  ```
- Each Django model has at least one manager and the default is `objects`.
  The `get` method returns a single result or throws `DoesNotExist` or
  `MultipleObjectsReturned`. `get_or_create` gets a single object or creates it
  if it doesn't exist and returns a tuple of the object and a boolean letting you
  know if it created the object or not. As a separate example (not a
  `get_or_create` alternative), `User.objects.all()` fetches every `User`
  object. Note that QuerySets are lazy so very efficient. You can filter a
  QuerySet with `filter`:

  ```py
  posts = Post.objects.filter(title='Who was Django Reinhardt?')
  print(posts.query) # outputs the SQL query
  post = Post.objects.filter(id__exact=1)
  post = Post.objects.filter(id=1) # The same since exact is assumed
  post = Post.objects.filter(title__iexact='who was django reinhardt?')
  post = Post.objects.filter(title__contains='Django')
  post = Post.objects.filter(title__icontains='django')
  posts = Post.objects.filter(id__in=[1,3]) # Return posts 1 and 3
  posts = Post.objects.filter(id__gt=3) # id greater than 3
  posts = Post.objects.filter(id__gte=3) # id greater than or equal to 3
  posts = Post.objects.filter(id__lt=3) # id less than 3
  post = Post.objects.filter(publish__date=date(2024, 1, 31))
  ```

- As you see above, two underscores are used to define the lookup type with the
  format `field__lookup`. I didn't go through all of them above, but there's also
  `lte`, `startswith` and `istartswith`, `endswith` and `iendswith`, for dates
  `year`, `month`, `day`, `date__gt`, and for related objects, e.g.
  `author__username='admin'`, which can also chain with `startswith` or other
  operators. You can also query multiple fields by separating each by a comma
  like `Post.objects.filter(publish__year=2024, author__username='admin')`.
  You can also chain multiple `filter` calls or add an `exclude` to remove
  certain matches. And you can specify `order_by` where ascending is implied
  but order can be reversed by prefixing a `-` in front of the field name. You
  can even `order_by('?')` for a random order. You can use array indexing and
  slicing to return certain results also like `Post.objects.all()[:5]`. The
  `count()` method returns the number of objects in the QuerySet and `exists()`
  tells you if there are any results. On any of the returned objects above, you
  could delete them by running `post.delete()`.
- When you `filter` on multiple fields, the queries are joined with AND. To
  build more complex queries like A or B, you can use `Q` objects.

  ```py
  from django.db.models import Q
  starts_who = Q(title__istartswith='who')
  starts_why = Q(title__istartswith='why')
  posts = Post.objects.filter(starts_who | starts_why)
  ```

- Since QuerySets are lazy, you can add `filter` and other operations to them
  one at a time and it won't hit the database until evaluated.
- The default manager for every model is the `objects` manager that retrieves
  all the objects in the database. You can also create your own managers, either
  by adding methods to an existing manager like `Post.objects.custom_method()`
  or modifying the initial QuerySet of a new manager like
  `Post.published.all()`. We'll use the second way to define a manager for
  published posts:

  ```py
  # mysite/blog/models.py
  class PublishedManager(models.Manager):
      def get_queryset(self):
          return (
              super().get_queryset().filter(status=Post.Status.PUBLISHED)
          )

  class Post(models.Model):
      # model fields
      objects = models.Manager() # The default manager
      published = PublishedManager() # Our custom manager.

      class Meta:
          ordering = ['-publish']
          indexes = [
              models.Index(fields=['-publish']),
          ]

      def __str__(self): 
          return self.title
  ```

- The first manager declared in a model becomes the default manager. `objects`
  is only created automatically if no manager is defined in the model.
- A Django view is just a Python function that receives a web request and returns
  a web response. The logic to return the response goes inside the view.
  Every view requires at least the `request` argument as a parameter. `render`
  takes the request, a template path, and the context variables and returns
  an `HttpResponse`. Any variable set by the template context processors is
  accessible by the given template.

  ```py
  # mysite/blog/views.py
  from django.shortcuts import render
  from .models import Post

  def post_list(request):
      posts = Post.published.all()
      return render(
          request,
          'blog/post/list.html',
          {'posts':posts}
      )
  ```

- Django provides a `get_object_or_404` shortcut that we use in `post_detail`.
- We associated URLs with views by starting a `urls.py` file in the app folder:

  ```py
  # mysite/blog/urls.py
  from django.urls import path
  from . import views

  app_name = 'blog'
  urlpatterns = [
      # post views
      path('', views.post_list, name='post_list'),
      path('<int:id>/', views.post_detail, name='post_detail'),
  ]
  ```

- Any value specified in the URL pattern as `<parameter>` is captured as a
  string, and you can use path converters such as `<int:year>` to match and
  return an integer. `<slug:post>` would match a slug and bind it to `post`.
  If `path` isn't flexible enough, `re_path` lets you use regular expressions.
- We also needed to declare `admin/` and `blog/` in `mysite/urls.py`.
- Django has a powerful template language:
  - Template tags control the rendering of the template and look like: 
    `{% tag %}`.
  - Template variables get replaced with values when the template is rendered and
    look like `{{ variable }}`.
  - Template filters allow you to modify variables for display and look like
    `{{ variable|filter }}`.

## Chapter 2 - Enhancing Your Blog and Adding Social Features

- You can implement `get_absolute_url()` method in your models to return the
  canonical URL for the object. The `post_detail` URL in the `blog` namespace can
  be referred to outside of urls.py as `blog:post_detail`.

  ```py
  # mysite/blog/models.py
  from django.conf import settings
  from django.db import models
  from django.urls import reverse # new import!
  from django.utils import timezone

  # ...
  class Post(models.Model):
      # ...
      def __str__(self):
          return self.title

      def get_absolute_url(self):
          return reverse('blog:post_detail', args=[self.id])
  ```

- We can define a slug as unique for a publish date by editing the field
  definition in models.py: 
  `slug = models.SlugField(max_length=250, unique_for_date='publish')`. Publish
  is a DateTime field, but `unique_for_date` verifies uniqueness only against
  the date. Remember when changing the model to make and apply migrations.
- Django has an easy to add `Paginator` that we will use for blog posts:

  ```py
  from django.http import Http404
  from django.core.paginator import Paginator
  # ...

  def post_list(request):
      post_list = Post.published.all()
      # Pagination with 3 posts per page
      paginator = Paginator(post_list, 3)
      page_number = request.GET.get('page', 1)
      posts = paginator.page(page_number)
      return render(request, "blog/post/list.html", {"posts": posts})
  ```

- Then we add a pagination template:

  ```py
  # mysite/blog/templates/pagination.html
  <div class="pagination">
    <span class="step-links">
      {% if page.has_previous %}
        <a href="?page={{ page.previous_page_number }}">Previous</a>
      {% endif %}
      <span class="current">
        Page {{ page.number }} of {{ page.paginator.num_pages }}.
      </span>
      {% if page.has_next %}
        <a href="?page={{ page.next_page_number }}">Next</a>
      {% endif %}
    </span>
  </div>
  ```

- And add this line to our `blog/templates/blog/post/list.html` template:
  `{% include "pagination.html" with page=posts %}`.
- We also want to handle exceptional circumstances, so we add exception handling
  for `EmptyPage` to `blog/views.py`:

  ```py
  # mysite/blog/views.py
  from django.core.paginator import EmptyPage, PageNotAnInteger, Paginator
  # ...
  def post_list(request):
      # ...
      try:
          posts = paginator.page(page_number)
      except PageNotAnInteger:
          # If page_number is not an integer get the first page
          posts = paginator.page(1)
      except EmptyPage:
          # If page_number is out of range get last page of results
          posts = paginator.page(paginator.num_pages)
      return render(request, "blog/post/list.html", {"posts": posts})
  ```

- We have built the site so far using function based views, but Django also
  supports class-based views. Class-based views allow you to organize code
  related to different HTTP methods as separate methods and use multiple
  inheritance to create reusable view classes (also known as *mixins*). The
  following is the equivalent to our function-based `post_list`.

  ```py
  # mysite/blog/views.py
  from django.core.paginator import EmptyPage, PageNotAnInteger, Paginator
  from django.shortcuts import get_object_or_404, render
  from django.views.generic import ListView

  from .models import Post


  class PostListView(ListView):
      """
      Alternative post list view
      """

      queryset = Post.published.all()
      context_object_name = "posts"
      paginate_by = 3
      template_name = "blog/post/list.html"

  # mysite/blog/urls.py
      # ...
      # path("", views.post_list, name="post_list"),
      path('', views.PostListView.as_view(), name='post_list'),
      # ...
  ```

- But the class view passes the page as `page_obj`, so we need to adjust our 
  template to refer to that instead of `posts`. Note that we no longer have our
  custom exception handling and bad `page` values just trigger 404.
- Now we add a form so users can email posts:

  ```py
  # mysite/blog/forms.py
  from django import forms
  class EmailPostForm(forms.Form):
      name = forms.CharField(max_length=25)
      email = forms.EmailField()
      to = forms.EmailField()
      comments = forms.CharField(required=False, widget=forms.Textarea)
  ```

- Forms can go anywhere, but by convention we place them in `forms.py`. We need
  to link to this new form in `views.py`.

  ```py
  # mysite/blog/views.py
  # ...
  from .forms import EmailPostForm
  # ...
  def post_share(request, post_id):
      # Retrieve post by id
      post = get_object_or_404(Post, id=post_id, status=Post.Status.PUBLISHED)
      if request.method == "POST":
          # Form was submitted
          form = EmailPostForm(request.POST)
          if form.is_valid():
              # Form fields passed validation
              cd = form.cleaned_data
              # ... send email
      else:
          form = EmailPostForm()
      return render(request, "blog/post/share.html", 
                    {"post": post, "form": form})
  ```

- The following settings allow you to define the SMTP configuration to send
  emails with Django:
  - EMAIL_HOST: The SMTP server host; the default is `localhost`
  - EMAIL_PORT: The SMTP port; the default is 25
  - EMAIL_HOST_USER: The username for the SMTP server
  - EMAIL_HOST_PASSWORD: The password for the SMTP server
  - EMAIL_USE_TLS: Whether to use TLS
  - EMAIL_USE_SSL: Whether to use SSL
  - DEFAULT_FROM_EMAIL: The sender email address (optional)
- You can manage the environment variables easily by running
  `python -m pip install python-decouple` and creating a `.env` file in the
  project's root directory. Make an app password in gmail at the
  [Google App Passwords page](https://myaccount.google.com/apppasswords) and
  put the password in your `.env` file, and refer to these values from
  `settings.py`.
- You actually send the email with `send_mail` from `django.core.mail`. Here's
  the full `post_share` method with that part filled in:

  ```py
  # mysite/blog/views.py
  def post_share(request, post_id):
      # Retrieve post by id
      post = get_object_or_404(Post, id=post_id, status=Post.Status.PUBLISHED)
      sent = False
      if request.method == "POST":
          # Form was submitted
          form = EmailPostForm(request.POST)
          if form.is_valid():
              # Form fields passed validation
              cd = form.cleaned_data
              post_url = request.build_absolute_uri(post.get_absolute_url())
              subject = (
                  f"{cd['name']} ({cd['email']}) " f"recommends you read {post.title}"
              )
              message = (
                  f"Read {post.title} at {post_url}\n\n"
                  f"{cd['name']}'s comments: {cd['comments']}"
              )
              send_mail(
                  subject=subject,
                  message=message,
                  from_email=None,
                  recipient_list=[cd["to"]],
              )
              sent = True
      else:
          form = EmailPostForm()
      return render(
          request, "blog/post/share.html", {"post": post, "form": form, "sent": sent}
      )
  ```
- You can render a form in your view with `form.as_p`, `form.as_ul`, or
  `form.as_table` assuming your form is in `form` variable. Also remember to
  include `{% csrf_token %}` in any form submitted by POST.
- The `Comment` model is rather straightforward but worth looking at since it
  has a `ForeignKey`. Each `Comment` has a `Post` and each `Post` can have
  many `Comment`s. We define the many-to-one relationship in the `Comment`.
  We use `related_name` to call the field in `Post` `comments`. If we did not,
  it would default to the model name in lowercase followed by `_set`, so
  `comment_set`.

  ```py
  # mysite/blog/models.py
  class Comment(models.Model):
      post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name="comments")
      name = models.CharField(max_length=80)
      email = models.EmailField()
      body = models.TextField()
      created = models.DateTimeField(auto_now_add=True)
      updated = models.DateTimeField(auto_now=True)
      active = models.BooleanField(default=True)

      class Meta:
          ordering = ["created"]
          indexes = [models.Index(fields=["created"])]

      def __str__(self):
          return f"Comment by {self.name} on {self.post}"
  ```

- We also want to add our `Comment` model to the admin site:

  ```py
  # mysite/blog/admin.py
  from django.contrib import admin

  from .models import Comment, Post
  # ...
  @admin.register(Comment)
  class CommentAdmin(admin.ModelAdmin):
      list_display = ["name", "email", "post", "created", "active"]
      list_filter = ["active", "created", "updated"]
      search_fields = ["name", "email", "body"]
  ```

- This time we're going to use `ModelForm` since we have a `Comment` model.

  ```py
  # mysite/blog/forms.py
  from django import forms

  from .models import Comment

  class CommentForm(forms.ModelForm):
      class Meta:
          model = Comment
          fields = ['name', 'email', 'body']
  ```

- We handle the form a little differently for `Comment` too:

  ```py
  # mysite/blog/views.py
  # ...
  from django.views.decorators.http import require_POST
  from django.views.generic import ListView

  from .forms import CommentForm, EmailPostForm
  # ...
  @require_POST
  def post_comment(request, post_id):
      post = get_object_or_404(Post, id=post_id, status=Post.Status.PUBLISHED)
      comment = None
      # A comment was posted
      form = CommentForm(data=request.POST)
      if form.is_valid():
          # Create a Comment object without saving it to the database
          comment = form.save(commit=False)
          # Assign the post to the comment
          comment.post = post
          # Save the comment to the database
          comment.save()
      return render(
          request,
          "blog/post/comment.html",
          {"post": post, "form": form, "comment": comment},
      )
  ```

- We also add a new line to our `mysite/blog/urls.py`:

  ```py
  # ...
    path('<int:post_id>/comment/', views.post_comment, name='post_comment'),
  ```

- We're going to write our comment form as an include to put it within our
  `post_detail` but also let us display it when there are errors.

  ```py
  # mysite/blog/templates/blog/post/includes/comment_form.html
  <h2>Add a new comment</h2>
  <form action="{% url "blog:post_comment" post.id %}" method="post">
    {{ form.as_p }}
    {% csrf_token %}
    <p><input type="submit" value="Add comment"></p>
  </form>

  # mysite/blog/templates/blog/post/comment.html
  {% extends "blog/base.html" %}
  {% block title %}Add a comment{% endblock %}
  {% block content %}
    {% if comment %}
      <h2>Your comment has been added.</h2>
        <p><a href="{{ post.get_absolute_url }}">Back to the post</a></p>
    {% else %}
      {% include "blog/post/includes/comment_form.html" %}
    {% endif %}
  {% endblock %}

  # mysite/blog/views.py
  def post_detail(request, year, month, day, post):
      post = get_object_or_404(
          Post,
          status=Post.Status.PUBLISHED,
          slug=post,
          publish__year=year,
          publish__month=month,
          publish__day=day,
      )
      comments = post.comments.filter(active=True)
      form = CommentForm()
      return render(
          request,
          "blog/post/detail.html",
          {"post": post, "comments": comments, "form": form},
      )

  # mysite/blog/templates/blog/post/detail.html
  {% extends "blog/base.html" %}
  {% block title %}{{ post.title }}{% endblock %}
  {% block content %}
    <h1>{{ post.title }}</h1>
    <p class="date">
      Published {{ post.publish }} by {{ post.author }}
    </p>
    {{ post.body|linebreaks }}
    <p>
      <a href="{% url "blog:post_share" post.id %}">
        Share this post
      </a>
    </p>
    {% with comments.count as total_comments %}
      <h2>
        {{ total_comments }} comment{{ total_comments|pluralize }}
      </h2>
    {% endwith %}
    {% for comment in comments %}
      <div class="comment">
        <p class="info">
          Comment {{ forloop.counter }} by {{ comment.name }}
          {{ comment.created }}
        </p>
        {{ comment.body|linebreaks }}
      </div>
    {% endfor %}
    {% include "blog/post/includes/comment_form.html" %}
  {% endblock %}
  ```

- The `{% with %}` template tag is useful for avoiding hitting the database or
  accessing expensive methods multiple times.
- It is also possible to render a form with custom HTML. We will use this to
  place Name and Email side-by-side:

  ```py
  {% for field in form %}
    <div class="my-div">
      {{ field.errors }}
      {{ field.label_tag }} {{ field }}
      <div class="help-text">{{ field.help_text|safe }}</div>
    </div>
  {% endfor %}

  # mysite/blog/templates/blog/post/includes/comment_form.html
  <h2>Add a new comment</h2>
  <form action="{% url "blog:post_comment" post.id %}" method="post">
    <div class="left">
      {{ form.name.as_field_group }}
    </div>
    <div class="left">
      {{ form.email.as_field_group }}
    </div>
    {{ form.body.as_field_group }}
    {% csrf_token %}
    <p><input type="submit" value="Add comment"></p>
  </form>
  ```

- `as_field_group` renders each field including label and help text.

## Chapter 3 - Extending Your Blog Application

- In INSTALLED_APPS, it is good to keep Django packages at the top,
  third-party packages in the middle, and local applications at the end.
- Tags are easy to add to Django with `django-taggit`.
- `django.db.models` includes `Avg`, `Max`, `Min`, and `Count`.
- You can add custom tags to Django with `simple_tag` or `inclusion_tag`.
  You use the `@register.simple_tag` decorator to register a function as a
  simple tag. The function name will be the tag name. To use it, you must
  `{% load blog_tags %}` in the template. You need to restart your server after
  adding a new template tags module.

  ```py
  from django import template
  from django.db.models import Count

  from ..models import Post

  register = template.Library()


  @register.simple_tag
  def total_posts():
      return Post.published.count()


  @register.simple_tag
  def get_most_commented_posts(count=5):
      return Post.published.annotate(total_comments=Count("comments")).order_by(
          "-total_comments"
      )[:count]


  @register.inclusion_tag("blog/post/latest_posts.html")
  def show_latest_posts(count=5):
      latest_posts = Post.published.order_by("-publish")[:count]
      return {"latest_posts": latest_posts}
  ```

- We can also add a markdown filter to Django. Template filters are registered
  like template tags. Because the markdown package uses a `markdown` function,
  we have named our function `markdown_format` but are using the filter name
  `markdown`. We also had to pip install the markdown package. Templates
  normally escape HTML returned by functions, but we are using `mark_safe` here
  to mark the result as safe HTML.

  ```py
  # mysite/blog/templatetags/blog_tags.py
  import markdown
  # ...
  from django.utils.safestring import mark_safe
  # ...
  @register.filter(name='markdown')
  def markdown_format(text):
      return mark_safe(markdown.markdown(text))
  ```

- To use sitemaps, first we need to add `django.contrib.sites` and
  `django.contrib.sitemaps` to our `INSTALLED_APPS` in `settings.py`. We also
  need to define a `SITE_ID` there. Then we need to run migrations and write a
  `mysite/blog/sitemaps.py` file:

  ```py
  # mysite/blog/sitemaps.py
  from django.contrib.sitemaps import Sitemap
  from .models import Post
  class PostSitemap(Sitemap):
      changefreq = 'weekly'
      priority = 0.9
      def items(self):
          return Post.published.all()
      def lastmod(self, obj):
          return obj.updated
  ```

- The sitemap exists outside the `blog` application, so we want to add a URL to
  `mysite/urls.py`:

  ```py
  # mysite/urls.py
  from django.contrib import admin
  from django.contrib.sitemaps.views import sitemap
  from django.urls import include, path
  from blog.sitemaps import PostSitemap

  sitemaps = {
      'posts': PostSitemap,
  }
  urlpatterns = [
      path("admin/", admin.site.urls),
      path("blog/", include("blog.urls", namespace="blog")),
      path('sitemap.xml', sitemap, {'sitemaps': sitemaps},
           name='django.contrib.sitemaps.views.sitemap')
  ]
  ```

- The default installed sitemap uses the domain `example.com` but you can
  update this at `http://127.0.0.1:8000/admin/sites/site/`, then click into
  the existing site entry to edit its domain.
- Django also has support for RSS feeds baked in. Add the following:

  ```py
  # mysite/blog/feeds.py
  import markdown
  from django.contrib.syndication.views import Feed
  from django.template.defaultfilters import truncatewords_html
  from django.urls import reverse_lazy
  from .models import Post
  class LatestPostsFeed(Feed):
      title = 'My blog'
      link = reverse_lazy('blog:post_list')
      description = 'New posts of my blog.'
      def items(self):
          return Post.published.all()[:5]
      def item_title(self, item):
          return item.title
      def item_description(self, item):
          return truncatewords_html(markdown.markdown(item.body), 30)
      def item_pubdate(self, item):
          return item.publish

  # mysite/blog/urls.py
  from .feeds import LatestPostsFeed
  urlpatterns = [
      # ...
      path('feed/', LatestPostsFeed(), name='post_feed'),
  ]
  ```

- Django supports basic search functionality with `contains` or `icontains` 
  like  `Post.objects.filter(body__contains='framework')`, but we are going to
  add in the `django.contrib.postgres` module to take advantage of Postgres
  full-text search features. Running postgres with Docker is as simple as
  running `docker pull postgres:16.2` then
  `docker run --name=blog_db -e POSTGRES_DB=blog -e POSTGRES_USER=blog \`
  `-e POSTGRES_PASSWORD=xxxxx -p 5432:5432 -d postgres:16.2`. Note that you
  also need to `pip install psycopg[binary]`.
- Thanks to Docker it was easy to run our new database, but it's empty. Django
  provides easy ways to load and dump data from the database into files called
  *fixtures*. To dump our entire sqllite database to JSON, we just run:
  `python manage.py dumpdata --indent=2 --output=mysite_data.json`. JSON is the
  default, but XML and YAML are also supported. You can limit the output to
  specific application models by providing application names to the command or
  even to a particular model with `app.Model`. `--format` lets you specify the
  format, and if you don't specify `--output` it defaults to STDOUT. To see
  more options run `python manage.py dumpdata --help`. After our data dump, we
  need to switch our application to use Postgres:

  ```py
  # mysite/mysite/settings.py
  DATABASES = {
      'default': {
          'ENGINE': 'django.db.backends.postgresql',
          'NAME': config('DB_NAME'),
          'USER': config('DB_USER'),
          'PASSWORD': config('DB_PASSWORD'),
          'HOST': config('DB_HOST'),
      }
  }

  # mysite/.env
  # ...
  DB_NAME=blog
  DB_USER=blog
  DB_PASSWORD=xxxxx
  DB_HOST=localhost
  ```

- We've already done all the `makemigrations` for our models, so we just need
  to `python manage.py migrate` to run our migrations. Then to load our dump
  `python manage.py loaddata mysite_data.json`.
- It turned out I should've generated the data dump a different way. The
  contenttypes, permission, and admin log tables reference things by id and
  are regenerated by the `migrate` command, so they should've been excluded:
  `python manage.py dumpdata --natural-foreign --exclude contenttypes \`
    `--exclude auth.permission --exclude admin.logentry --indent 2 \`
    `--output mysite_data.json`.
- We already have basic search functionality:

  ```py
  $ python manage.py shell
  >>> from blog.models import Post
  >>> Post.objects.filter(title__search='django')
  <QuerySet [<Post: Who was Django Reinhardt?>]>
  # To search multiple fields we need a SearchVector
  >>> from django.contrib.postgres.search import SearchVector
  >>> Post.objects.annotate(
  ...     search=SearchVector('title', 'body'),
  ... ).filter(search='django')
  <QuerySet [<Post: Markdown Post>, <Post: Django Unchained>, <Post: Who was Django Reinhardt?>]>
  ```

- Through using `annotate` and defining `SearchVector` with both fields, we are
  able to match the query against both the `title` and `body` of posts.
- Full-text search is intense. If you go over a few hundred rows, you should
  define a functional index that matches the search vector you are using.
  Read more at [Postgres Search Performance](https://docs.djangoproject.com/en/5.0/ref/contrib/postgres/search/#performance).
- So let's add our full-text search functionality:

  ```py
  # mysite/blog/forms.py
  class SearchForm(forms.Form):
      query = forms.CharField()

  # mysite/blog/views.py
  from django.contrib.postgres.search import SearchVector
  from .forms import CommentForm, EmailPostForm, SearchForm
  # ...
  def post_search(request):
      form = SearchForm()
      query = None
      results = []
      if 'query' in request.GET:
          form = SearchForm(request.GET)
          if form.is_valid():
              query = form.cleaned_data['query']
              results = (
                  Post.published.annotate(
                      search=SearchVector('title', 'body'),
                  ).filter(search=query)
              )
      return render(
          request,
          'blog/post/search.html',
          {
              'form': form,
              'query': query,
              'results': results
          }
      )

  # mysite/blog/templates/blog/post/search.html
  {% extends "blog/base.html" %}
  {% load blog_tags %}
  {% block title %}Search{% endblock %}
  {% block content %}
    {% if query %}
      <h1>Posts containing "{{ query }}"</h1>
      <h3>
        {% with results.count as total_results %}
          Found {{ total_results }} result{{ total_results|pluralize }}
        {% endwith %}
      </h3>
      {% for post in results %}
        <h4>
          <a href="{{ post.get_absolute_url }}">
            {{ post.title }}
          </a>
        </h4>
        {{ post.body|markdown|truncatewords_html:12 }}
      {% empty %}
        <p>There are no results for your query.</p>
      {% endfor %}
        <p><a href="{% url "blog:post_search" %}">Search again</a></p>
    {% else %}
      <h1>Search for posts</h1>
      <form method="get">
        {{ form.as_p }}
        <input type="submit" value="Search">
      </form>
    {% endif %}
  {% endblock %}

  # mysite/blog/urls.py
    path("search/", views.post_search, name="post_search"),
  ```

- So now we're searching by two fields, but we want to add stemming and
  ranking results. We will use `SearchQuery` which automatically stems and
  removes stop words and `SearchRank` from `django.contrib.postgres.search`.
  We modify views.py:

  ```py
  # mysite/blog/views.py
  from django.contrib.postgres.search import (
      SearchQuery, 
      SearchRank, 
      SearchVector
  )
  # ...
  def post_search(request):
  # ...
          if form.is_valid():
              query = form.cleaned_data["query"]
              search_vector = SearchVector("title", "body")
              search_query = SearchQuery(query)
              results = (
                  Post.published.annotate(
                      search=search_vector, rank=SearchRank(search_vector, search_query)
                  )
                  .filter(search=query)
                  .order_by("-rank")
              )
      return render(
          request,
          "blog/post/search.html",
          {"form": form, "query": query, "results": results},
      )
  ```

- If we had wanted to do stemming and stop word removing for Spanish, we
  could've passed `config='spanish'` to our `SearchVector` and `SearchQuery`.
- To weight title more highly than body, we just need to modify `SearchVector`
  and `results`:

  ```py
  # mysite/blog/views.py
              search_vector = SearchVector(
                  "title", weight='A'
              ) + SearchVector('body', weight='B')
              search_query = SearchQuery(query)
              results = (
                  Post.published.annotate(
                      search=search_vector, rank=SearchRank(search_vector, search_query)
                  )
                  .filter(rank__gte=0.3)
                  .order_by("-rank")
              )
  ```

- We can also search by trigram similarity. First run:
  `python manage.py makemigrations --name=trigram_ext --empty blog`. Then edit
  `blog/migrations/0006_trigram_ext.py`:

  ```py
  # mysite/blog/migrations/0006_trigram_ext.py
  from django.contrib.postgres.operations import TrigramExtension
  from django.db import migrations
  class Migration(migrations.Migration):
      dependencies = [
          ("blog", "0005_post_tags"),
      ]
      operations = [
          TrigramExtension()
      ]
  ```

- And run `python manage.py migrate blog`. And edit `views.py`:

  ```py
  from django.contrib.postgres.search import (
      SearchQuery, 
      SearchRank, 
      SearchVector, 
      TrigramSimilarity
  )
  # ...
  def post_search(request):
  # ...
              results = (
                  Post.published.annotate(
                      similarity=TrigramSimilarity('title', query)
                  )
                  .filter(similarity__gt=0.1)
                  .order_by("-similarity")
              )
  # ...
  ```

## Chapter 4 - Building a Social Website

- Normally we place our own apps at the bottom of `INSTALLED_APPS`, but for
  this project we are overriding standard authentication templates, so we
  need `account.apps.AccountConfig` listed before `django.contrib.admin`.
- We start with models for Users, Groups, and Permissions from `auth`, so our
  first task will be a login form.

  ```py
  # bookmarks/account/forms.py
  from django import forms
  class LoginForm(forms.Form):
      username = forms.CharField()
      password = forms.CharField(widget=forms.PasswordInput)

  # bookmarks/account/views.py
  from django.contrib.auth import authenticate, login
  from django.http import HttpResponse
  from django.shortcuts import render
  from .forms import LoginForm
  def user_login(request):
      if request.method == 'POST':
          form = LoginForm(request.POST)
          if form.is_valid():
              cd = form.cleaned_data
              user = authenticate(
                  request,
                  username=cd['username'],
                  password=cd['password']
              )
              if user is not None:
                  if user.is_active:
                      login(request, user)
                      return HttpResponse('Authenticated successfully')
                  else:
                      return HttpResponse('Disabled account')
              else:
                  return HttpResponse('Invalid login')
      else:
          form = LoginForm()
      return render(request, 'account/login.html', {'form': form})

  # bookmarks/account/urls.py
  from django.urls import path
  from . import views
  urlpatterns = [
      path('login/', views.user_login, name='login')
  ]

  # bookmarks/bookmarks/urls.py
  from django.contrib import admin
  from django.urls import include, path
  urlpatterns = [
      path("admin/", admin.site.urls),
      path('account/', include('account.urls')),
  ]

  # bookmarks/account/templates/base.html
  {% load static %}
  <!DOCTYPE html>
  <html>
    <head>
      <title>{% block title %}{% endblock %}</title>
      <link href="{% static "css/base.css" %}" rel="stylesheet">
    </head>
    <body>
      <div id="header">
        <span class="logo">Bookmarks</span>
      </div>
      <div id="content">
        {% block content %}
        {% endblock %}
      </div>
    </body>
  </html>

  # bookmarks/account/templates/account/login.html
  {% extends "base.html" %}
  {% block title %}Login{% endblock %}
  {% block content %}
    <h1>Login</h1>
    <p>Please, use the following form to login:</p>
    <form method="post">
      {{ form.as_p }}
      {% csrf_token %}
      <p><input type="submit" value="Login"></p>
    </form>
  {% endblock %}
  ```

- You'll notice `authenticate` and `login` are separate steps. `authenticate`
  verifies the credentials and upon validation returns a `User` object, and
  `login` sets the user in the current session using the authenticated `User`
  object in the current session context.
- We just created that Login form as an exercise. Django includes perfectly
  good `LoginView` and `LogoutView` views in `django.contrib.auth.views`. It
  also provides `PasswordChangeView` and `PasswordChangeDoneView` for password
  changes and `PasswordResetView`, `PasswordResetDoneView`, 
  `PasswordResetConfirmView`, and `PasswordResetCompleteView` for password
  resets. It's as simple as changing our `account/urls.py`:

  ```py
  # bookmarks/account/urls.py
  from django.contrib.auth import views as auth_views
  # ...
      # path("login/", views.user_login, name="login"),
      path("login/", auth_views.LoginView.as_view(), name="login"),
      path("logout/", auth_views.LogoutView.as_view(), name="logout"),
  ```

- And adding some templates. You want these in 
  `account/templates/registration`. Now we can start using the 
  `login_required` decorator in our views. It will automatically redirect to
  the login page if you aren't authenticated and set the `next` page as what
  you were trying to access:

  ```py
  from django.contrib.auth.decorators import login_required
  # ...
  @login_required
  def dashboard(request):
      return render(request, "account/dashboard.html", {"section": "dashboard"})
  ```

- The dashboard will start off as a simple place to land. We also need to set
  some variables in our `bookmarks/settings.py`:

  ```py
  # account/templates/account/dashboard.html
  {% extends "base.html" %}
  {% block title %}Dashboard{% endblock %}
  {% block content %}
    <h1>Dashboard</h1>
    <p>Welcome to your dashboard.</p>
  {% endblock %}

  # account/urls.py
      path('', views.dashboard, name='dashboard')

  # bookmarks/settings.py
  LOGIN_REDIRECT_URL = 'dashboard'
  LOGIN_URL = 'login'
  LOGOUT_URL = 'logout'
  ```
- You can access the current user from `request.user`. Even when no one is
  logged in, this is set to `AnonymousUser`. You can make sure the user is
  authenticated with `request.user.is_authenticated`.
- To add the password change views, we need new entries in URLs and new
  templates in `account/templates/registration`.

  ```py
  # account/urls.py
      path('password-change/', auth_views.PasswordChangeView.as_view(),
           name='password_change')
      path('password-change/done/', auth_views.PasswordChangeDoneView.as_view(),
           name='password_change_done')

  # account/templates/registration/password_change_form.html
  {% extends "base.html" %}
  {% block title %}Change your password{% endblock %}
  {% block content %}
    <h1>Change your password</h1>
    <p>Use the form below to change your password.</p>
    <form method="post">
      {{ form.as_p }}
      <p><input type="submit" value="Change"></p>
      {% csrf_token %}
    </form>
  {% endblock %}

  # account/templates/registration/password_change_done.html
  {% extends "base.html" %}
  {% block title %}Password change{% endblock %}
  {% block content %}
    <h1>Password changed</h1>
    <p>Your password has been successfully changed.</p>
  {% endblock %}
  ```
- And we can also add the password reset pages:

  ```py
  # account/urls.py
      path('password-reset/', auth_views.PasswordResetView.as_view(),
           name='password_reset'),
      path('password-reset/done/', auth_views.PasswordResetDoneView.as_view(),
           name='password_reset_done'),
      path('password-reset/<uidb64>/<token>/',
           auth_views.PasswordResetConfirmView.as_view(),
           name='password_reset_confirm'),
      path('password-reset/complete/',
           auth_views.PasswordResetCompleteView.as_view(),
           name='password_reset_complete'),

  # account/templates/registration/password_reset_form.html
  {% extends "base.html" %}
  {% block title %}Reset your password{% endblock %}
  {% block content %}
    <h1>Forgotten your password?</h1>
    <p>Enter your e-mail address to obtain a new password.</p>
    <form method="post">
      {{ form.as_p }}
      <p><input type="submit" value="Send e-mail"></p>
      {% csrf_token %}
    </form>
  {% endblock %}

  # account/templates/registration/password_reset_email.html
  Someone asked for password reset for email {{ email }}.
  Follow the link below:
  {{ protocol }}://{{ domain }}{% url "password_reset_confirm" uidb64=uid token=token %}
  Your username, in case you've forgotten: {{ user.get_username }}

  # account/templates/registration/password_reset_confirm.html
  {% extends "base.html" %}
  {% block title %}Reset your password{% endblock %}
  {% block content %}
    <h1>Reset your password</h1>
    {% if validlink %}
      <p>Please enter your new password twice:</p>
      <form method="post">
        {{ form.as_p }}
        {% csrf_token %}
        <p><input type="submit" value="Change my password" /></p>
      </form>
    {% else %}
      <p>
        The password reset link was invalid, possibly
        because it has already been used. Please request a new
        password reset.
      </p>
    {% endif %}
  {% endblock %}

  # account/templates/registration/password_reset_complete.html
  {% extends "base.html" %}
  {% block title %}Password reset{% endblock %}
  {% block content %}
    <h1>Password set</h1>
    <p>Your password has been set. You can <a href="{% url "login" %}">
    log in now</a></p>
  {% endblock %}

  # account/templates/registration/login.html
  # ...
        <p><input type="submit" value="Login"></p>
      </form>
      <p>
        <a href="{% url "password_reset" %}">Forgotten your password?</a>
      </p>
    </div>
  {% endblock %}
  ```

- We are also going to make email in our DEV environment write to stdout
  instead of using a mail server:

  ```py
  # bookmarks/bookmarks/settings.py
  EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
  ```

- Since we're using the default paths and views, we can also use the default
  urls instead of writing our own to urls.py:

  ```py
  # bookmarks/account/urls.py
  from django.urls import include, path
  urlpatterns = [
      path('', include('django.contrib.auth.urls')),
      path('', views.dashboard, name='dashboard'),
  ]
  ```

- So that brings in all the stuff we've been building by hand. So now we have
  login, logout, change password, reset password, and a dashboard. We want
  ways for users to register themselves though, so we'll need to design it.

  ```py
  # bookmarks/account/forms.py
  from django import forms
  from django.contrib.auth import get_user_model
  class LoginForm(forms.Form):
      username = forms.CharField()
      password = forms.CharField(widget=forms.PasswordInput)
  class UserRegistrationForm(forms.ModelForm):
      password = forms.CharField(
          label='Password', 
          widget=forms.PasswordInput
      )
      password2 = forms.CharField(
          label='Repeat password', 
          widget=forms.PasswordInput
      )
      class Meta:
          model = get_user_model()
          fields = ['username', 'first_name', 'email']
      def clean_password2(self):
          cd = self.cleaned_data
          if cd['password'] != cd['password2']:
              raise forms.ValidationError("Passwords don't match.")
          return cd['password2']

  # bookmarks/account/views.py
  from .forms import LoginForm, UserRegistrationForm
  # ...
  def register(request):
      if request.method == 'POST':
          user_form = UserRegistrationForm(request.POST)
          if user_form.is_valid():
              # Create a new user object but avoid saving it yet
              new_user = user_form.save(commit=False)
              # Set the chosen password
              new_user.set_password(user_form.cleaned_data['password'])
              new_user.save()
              return render(
                  request,
                  'account/register_done.html',
                  {'new_user': new_user}
              )
      else:
          user_form = UserRegistrationForm()
      return render(
          request,
          'account/register.html',
          {'user_form': user_form}
      )

  # bookmarks/account/urls.py
      path('register/', views.register, name='register'),

  # bookmarks/account/templates/account/register.html
  {% extends "base.html" %}
  {% block title %}Create an account{% endblock %}
  {% block content %}
    <h1>Create an account</h1>
    <p>Please, sign up using the following form:</p>
    <form method="post">
      {{ user_form.as_p }}
      {% csrf_token %}
      <p><input type="submit" value="Create my account"></p>
    </form>
  {% endblock %}

  # bookmarks/account/templates/account/register_done.html
  {% extends "base.html" %}
  {% block title %}Welcome{% endblock %}
  {% block content %}
    <h1>Welcome {{ new_user.first_name }}!</h1>
    <p>
      Your account has been successfully created.
      Now you can <a href="{% url "login" %}">login</a>
    </p>
  {% endblock %}
  ```

- You can include a `clean_<fieldname>()` method for any form field to clean
  the value or raise a validation error for a specific field. There is also
  a general `clean` method you can override to validate the entire form which
  is useful when fields depend on each other. Django also provides a
  `UserCreationForm` in `django.contrib.auth.forms` that is very similar to
  what we just created.
- `set_password` in the user model handles password hashing instead of storing
  the raw password.
- You can extend the Django user model by defining a profile model that
  contains a one-to-one relationship with the Django user model plus any
  additional fields.

  ```py
  # bookmarks/account/models.py
  from django.db import models
  from django.conf import settings
  class Profile(models.Model):
      user = models.OneToOneField(
          settings.AUTH_USER_MODEL,
          on_delete=models.CASCADE
      )
      date_of_birth = models.DateField(blank=True, null=True)
      photo = models.ImageField(
          upload_to='users/%Y/%m/%d/',
          blank=True
      )
      def __str__(self):
          return f'Profile of {self.user.username}'
  ```

- You should use `get_user_model()` and `AUTH_USER_MODEL` setting to retrieve
  the user model instead of referring to `auth.User` directly.
- Pillow image library is required by Django to handle images with 
  `ImageField`. Install it with pip. Also add a bit of config:

  ```py
  # bookmarks/bookmarks/settings.py
  MEDIA_URL = 'media/'
  MEDIA_ROOT = BASE_DIR / 'media'

  # bookmarks/bookmarks/urls.py
  from django.conf import settings
  from django.conf.urls.static import static
  from django.contrib import admin
  from django.urls import include, path

  urlpatterns = [
      path("admin/", admin.site.urls),
      path("account/", include("account.urls")),
  ]
  if settings.DEBUG:
      urlpatterns += static(
          settings.MEDIA_URL,
          document_root=settings.MEDIA_ROOT
      )
  ```

- `static` is very inefficient. Never serve your static files with Django in
  Production. We will cover how to do so in Chapter 17, "Going Live".
- We also want to be able to edit `User` and `Profile`:

  ```py
  # bookmarks/account/forms.py
  from .models import Profile
  class UserEditForm(forms.ModelForm):
      class Meta:
          model = get_user_model()
          fields = ["first_name", "last_name", "email"]
  class ProfileEditForm(forms.ModelForm):
      class Meta:
          model = Profile
          fields = ["date_of_birth", "photo"]

  # bookmarks/account/views.py
  # The book creates the Profile in register() right after new_user.save().
  # I replaced that with a post_save signal (see the end of Chapter 7), so
  # register() doesn't create profiles itself.

  # bookmarks/account/views.py
  from .forms import (
      LoginForm, 
      ProfileEditForm, 
      UserEditForm, 
      UserRegistrationForm
  )
  # ...
  @login_required
  def edit(request):
      if request.method == "POST":
          user_form = UserEditForm(
              instance=request.user, 
              data=request.POST
          )
          profile_form = ProfileEditForm(
              instance=request.user.profile,
              data=request.POST,
              files=request.FILES
          )
          if user_form.is_valid() and profile_form.is_valid():
              user_form.save()
              profile_form.save()
      else:
          user_form = UserEditForm(instance=request.user)
          profile_form = ProfileEditForm(instance=request.user.profile)
      return render(
          request,
          "account/edit.html",
          {"user_form": user_form, "profile_form": profile_form},
      )

  # bookmarks/account/urls.py
      path("edit/", views.edit, name="edit"),

  # bookmarks/account/templates/account/edit.html
  {% extends "base.html" %}
  {% block title %}Edit your account{% endblock %}
  {% block content %}
    <h1>Edit your account</h1>
    <p>You can edit your account using the following form:</p>
    <form method="post" enctype="multipart/form-data">
      {{ user_form.as_p }}
      {{ profile_form.as_p }}
      {% csrf_token %}
      <p><input type="submit" value="Save changes"></p>
    </form>
  {% endblock %}
  ```

- You can also override the user model with a custom model by inheriting from
  Django's `AbstractUser` class. Doing so offers flexibility but might result
  in more difficult integration with pluggable applications that interact
  directly with Django's `auth` user model.

## Chapter 5 - Implementing Social Authentication

- Django includes a messages framework that is enabled by default and allows
  you to display one-time notifications to users. Messages are displayed and
  cleared in the next request from the user.

  ```py
  from django.contrib import messages
  messages.error(request, 'Something went wrong')
  ```

- You can use `add_message()`, `success()`, `info()`, `warning()`, `error()`,
  and `debug()` to add different messages. The base template is a good place
  to handle messages so they can be displayed on any page.

  ```py
  # bookmarks/account/templates/base.html
  # ...
      </div>
      {% if messages %}
        <ul class="messages">
          {% for message in messages %}
            <li class="{{ message.tags }}">
              {{ message|safe }}
              <a href="#" class="close">x</a>
            </li>
          {% endfor %}
        </ul>
      {% endif %}
      <div id="content">
  # ...
  ```

- And let's add our first messages to `edit` in `account/views.py`:

  ```py
  # bookmarks/account/views.py
  from django.contrib import messages
  # ...
  @login_required
  def edit(request):
      if request.method == "POST":
          user_form = UserEditForm(instance=request.user, data=request.POST)
          profile_form = ProfileEditForm(
              instance=request.user.profile, data=request.POST, files=request.FILES
          )
          if user_form.is_valid() and profile_form.is_valid():
              user_form.save()
              profile_form.save()
              messages.success(request, 'Profile updated successfully')
          else:
              messages.error(request, 'Error updating your profile')
      else:
          user_form = UserEditForm(instance=request.user)
          profile_form = ProfileEditForm(instance=request.user.profile)
      return render(
          request,
          "account/edit.html",
          {"user_form": user_form, "profile_form": profile_form},
      )
  ```

- When you called `authenticate`, Django tries to authenticate a user against
  each of the backends in `AUTHENTICATION_BACKENDS` until one successfully
  authenticates the user. A backend is a class that provides an `authenticate`
  method that takes a `request` object and user credentials as parameters
  and returns a `user` object if the credentials are valid and `None`
  otherwise and a `get_user()` method that takes a user ID parameter and
  returns a `user` object. Let's make a backend that authenticates by email:

  ```py
  # bookmarks/account/authentication.py
  from django.contrib.auth.models import User
  class EmailAuthBackend:
      """
      Authenticate using an e-mail address.
      """
      def authenticate(self, request, username=None, password=None):
          try:
              user = User.objects.get(email=username)
              if user.check_password(password):
                  return user
              return None
          except (User.DoesNotExist, User.MultipleObjectsReturned):
              return None
      def get_user(self, user_id):
          try:
              return User.objects.get(pk=user_id)
          except User.DoesNotExist:
              return None
  ```

- Then you just add the following to `bookmarks/settings.py`:

  ```py
  AUTHENTICATION_BACKENDS = [
      'django.contrib.auth.backends.ModelBackend',
      'account.authentication.EmailAuthBackend',
  ]
  ```

- Now to ensure unique emails, we need to enforce it in our 
  `UserRegistrationForm` and `UserEditForm`:

  ```py
  # bookmarks/account/forms.py
  class UserRegistrationForm(forms.ModelForm):
      # ...
      def clean_email(self):
          data = self.cleaned_data["email"]
          User = get_user_model()
          if User.objects.filter(email=data).exists():
              raise forms.ValidationError("Email already in use.")
          return data

  class UserEditForm(forms.ModelForm):
      def clean_email(self):
          data = self.cleaned_data["email"]
          User = get_user_model()
          qs = User.objects.exclude(id=self.instance.id).filter(email=data)
          if qs.exists():
              raise forms.ValidationError("Email already in use.")
          return data
  ```

- Now we want to enable Social Auth so people can login with their Gmail
  accounts. First `python -m pip install social-auth-app-django==5.4.0`.
  Then add it to `INSTALLED_APPS` in `settings.py` and run migrate. Then we
  include the `social-auth/` patterns in `bookmarks/urls.py`.

  ```py
      path("social-auth/", include("social_django.urls", namespace="social")),
  ```

- Google does allow redirection of users to `localhost`, but we are going
  to setup a host entry for `127.0.0.1` to `mysite.com` and use that.
  We will also need to add `"mysite.com"` to `ALLOWED_HOSTS` in
  `bookmarks/settings.py`. We should also add `"localhost"` and `"127.0.0.1"`
  like `ALLOWED_HOSTS = ["mysite.com", "localhost", "127.0.0.1"]`. It defaults
  to allowing the latter two only, but they need to be included once you set it.
- We also want to start running SSL in our dev server. This requires some
  extensions. So we install `django-extensions` which includes RunServerPlus
  among other things, `werkzeug` for debugging RunServerPlus, and `pyOpenSSL`
  to use the SSL/TLS functionality of RunServerPlus. We also add
  `django_extensions` to `INSTALLED_APPS`. Now we can run our server with
  `python manage.py runserver_plus --cert-file cert.crt`.
- Google OAuth setup took many pages of book but amounted to very little code.
  You really just add an authentication backend, 
  [create a project](https://console.cloud.google.com/projectcreate) with 
  Google, set your OAuth variables, and add a login button. You also need to
  add `associate_by_email` to `SOCIAL_AUTH_PIPELINE`, so a Google login whose
  email matches an existing account uses that account instead of creating a
  duplicate. (The book also adds a pipeline step to create profiles, but the
  Chapter 7 signal handles that now.) You can see the final product in the
  bookmarks folder. Here's a brief overview of changes:

  ```py
  # bookmarks/settings.py
  AUTHENTICATION_BACKENDS = [
    "django.contrib.auth.backends.ModelBackend",
    "account.authentication.EmailAuthBackend",
    "social_core.backends.google.GoogleOAuth2",
  ]

  # https://console.cloud.google.com/projectcreate
  # Enter a Project name (Bookmarks) and click CREATE
  # Under APIS & Services, click Credentials
  # Click OAuth client ID and click CREATE CREDENTIALS
  # then CONFIGURE CONSENT SCREEN and choose External then CREATE
  # Under App name use Bookmarks and your email for support
  # For Authorized domains enter mysite.com
  # Enter your email under Developer contact information and SAVE AND CONTINUE
  # Don't change anything in Scopes and SAVE AND CONTINUE
  # In Test users, add your Google user to Test users and SAVE AND CONTINUE
  #   (Newer console: Test users are under Google Auth Platform > Audience)
  # Verify the summary and click BACK TO DASHBOARD
  # Then click Credentials->Create credentials->OAuth client ID and enter:
  #   Application type: Web application
  #   Name: Bookmarks
  #   Authorized JavaScript origins: not needed (server-side OAuth flow)
  #   Authorized redirect URIs: 
  #     https://mysite.com:8000/social-auth/complete/google-oauth2/
  # Then click CREATE and get your Client ID and Client secret keys

  # bookmarks/.env - these are from Google registration
  GOOGLE_OAUTH2_KEY=xxxx
  GOOGLE_OAUTH2_SECRET=xxxx

  # Run `pip install python-decouple==3.8`

  # bookmarks/settings.py
  from decouple import config
  # ...
  SOCIAL_AUTH_GOOGLE_OAUTH2_KEY = config('GOOGLE_OAUTH2_KEY')
  SOCIAL_AUTH_GOOGLE_OAUTH2_SECRET = config('GOOGLE_OAUTH2_SECRET')
  SOCIAL_AUTH_PIPELINE = [
      "social_core.pipeline.social_auth.social_details",
      "social_core.pipeline.social_auth.social_uid",
      "social_core.pipeline.social_auth.auth_allowed",
      "social_core.pipeline.social_auth.social_user",
      "social_core.pipeline.user.get_username",
      "social_core.pipeline.social_auth.associate_by_email",
      "social_core.pipeline.user.create_user",
      "social_core.pipeline.social_auth.associate_user",
      "social_core.pipeline.social_auth.load_extra_data",
      "social_core.pipeline.user.user_details",
  ]

  # bookmarks/account/templates/registration/login.html
  {% block content %}
    # ...
    <div class="social">
      <ul>
        <li class="google">
          <a href="{% url "social:begin" "google-oauth2" %}">
            Sign in with Google
          </a>
        </li>
      </ul>
    </div>
  {% endblock %}
  ```

## Chapter 6 - Sharing Content on Your Website

- Now we're going to need a place for images, so we create and `images` app
  and add a new `Image` model.

  ```py
  # bookmarks/images/models.py
  from django.conf import settings
  from django.db import models
  from django.utils.text import slugify


  class Image(models.Model):
      user = models.ForeignKey(
          settings.AUTH_USER_MODEL,
          related_name="images_created",
          on_delete=models.CASCADE,
      )
      title = models.CharField(max_length=200)
      slug = models.SlugField(max_length=200, blank=True)
      url = models.URLField(max_length=2000)
      image = models.ImageField(upload_to="images/%Y/%m/%d/")
      description = models.TextField(blank=True)
      created = models.DateTimeField(auto_now_add=True)
      users_like = models.ManyToManyField(
          settings.AUTH_USER_MODEL,
          related_name='images_liked',
          blank=True
      )

      def save(self, *args, **kwargs):
          if not self.slug:
              self.slug = slugify(self.title)
          super().save(*args, **kwargs)

      class Meta:
          indexes = [
              models.Index(fields=["-created"]),
          ]
          ordering = ["-created"]

      def __str__(self):
          return self.title
  ```

- A `User` can post many `Image`s, so we define the `user` field as a
  `ForeignKey` that appears as an `images_created` field on `User`.
  `ForeignKey` fields and `unique` fields automatically create an index.
- A `User` can also like many `Image`s, and an `Image` can be liked by many
  `User`s, so we define a many-to-many relationship between `Image` and `User`
  via `users_like` and the reciprocal `images_liked` field. For many-to-many
  relationships, Django generates an intermediary join table using the primary
  keys of both models. `ManyToManyField` provides a manager that allows you to
  retrieve related objects, such as `image.users_like.all()` and 
  `user.images_liked.all()`.
- Don't forget to make and run your migrations and register the new model with
  the admin site.

  ```py
  from django.contrib import admin

  from .models import Image

  @admin.register(Image)
  class ImageAdmin(admin.ModelAdmin):
      list_display = ['title', 'slug', 'image', 'created']
      list_filter = ['created']
  ```

- We also make a form to load images. We hide the `url` since we are sending
  it as a parameter via JavaScript.

  ```py
  # bookmarks/images/forms.py
  from django import forms

  from .models import Image

  class ImageCreateForm(forms.ModelForm):
      def clean_url(self):
          url = self.cleaned_data['url']
          valid_extensions = ['jpg', 'jpeg', 'png']
          extension = url.rsplit('.', 1)[1].lower()
          if extension not in valid_extensions:
              raise forms.ValidationError(
                  'The given URL does not match valid image extensions.'
              )
          return url 

      class Meta:
          model = Image
          fields = ["title", "url", "description"]
          widgets = {
              "url": forms.HiddenInput,
          }
  ```

- We also need to override the `save` method of our `ImageCreateForm` to
  fetch the image. For this we will use the `requests` library which you can
  install with `pip`. The `save` method receives a Boolean `commit` parameter
  that allows you to specify whether the object will be persisted to the
  database. If `commit` is `False` then `save` will return a model instance
  without saving to the database.

  ```py
  # bookmarks/images/forms.py
  import requests
  from django import forms
  from django.core.files.base import ContentFile
  from django.utils.text import slugify

  from .models import Image


  class ImageCreateForm(forms.ModelForm):
      def save(self, force_insert=False, force_update=False, commit=True):
          image = super().save(commit=False)
          image_url = self.cleaned_data['url']
          name = slugify(image.title)
          extension = image_url.rsplit('.', 1)[1].lower()
          image_name = f'{name}.{extension}'
          # download image from the given URL
          response = requests.get(image_url)
          image.image.save(
              image_name,
              ContentFile(response.content),
              save=False
          )
          if commit:
              image.save()
          return image
      # ...

  # bookmarks/images/views.py
  from django.contrib import messages
  from django.contrib.auth.decorators import login_required
  from django.shortcuts import redirect, render

  from .forms import ImageCreateForm


  @login_required
  def image_create(request):
      if request.method == "POST":
          form = ImageCreateForm(data=request.POST)
          if form.is_valid():
              cd = form.cleaned_data
              new_image = form.save(commit=False)
              new_image.user = request.user
              new_image.save()
              messages.success(request, "Image added successfully")
              return redirect(new_image.get_absolute_url())
      else:
          form = ImageCreateForm(data=request.GET)
      return render(
          request, 
          "images/image/create.html", 
          {"section": "images", "form": form}
      )

  # bookmarks/images/urls.py
  from django.urls import path

  from . import views

  app_name = 'images'
  urlpatterns = [
      path('create/', views.image_create, name='create')
  ]

  # bookmarks/bookmarks/urls.py
  urlpatterns = [
      # ...
      path("images/", include("images.urls", namespace="images")),
  ]

  # bookmarks/images/templates/images/image/create.html
  {% extends "base.html" %}
  {% block title %}Bookmark an image{% endblock %}
  {% block content %}
    <h1>Bookmark an image</h1>
    <img src="{{ request.GET.url }}" class="image-preview">
    <form method="post">
      {{ form.as_p }}
      {% csrf_token %}
      <input type="submit" value="Bookmark it!">
    </form>
  {% endblock %}
  ```

- Note: don't split template tags across multiple lines as that isn't
  supported by Django.
- The book also builds a JavaScript bookmarklet that finds images on any page
  and sends the chosen one to `image_create`. I'm not covering it in detail
  given its limitations: any site with a Content-Security-Policy `script-src`
  that doesn't list our domain (most security-conscious sites, including
  Wikipedia) blocks it outright.
- We also added an `image_detail` view and `detail.html` template plus
  a `get_absolute_url` method for the `Image` model.

  ```py
  # bookmarks/images/views.py
  from django.shortcuts import get_object_or_404, redirect, render
  from .models import Image
  def image_detail(request, id, slug):
      image = get_object_or_404(Image, id=id, slug=slug)
      return render(
          request, "images/image/detail.html", {"section": "images", "image": image}
      )

  # bookmarks/images/urls.py
      path("detail/<int:id>/<slug:slug>/", views.image_detail, name="detail"),

  # bookmarks/images/models.py
  from django.urls import reverse
  # ...
  class Image(models.Model):
      # ...
      def get_absolute_url(self):
          return reverse("images:detail", args=[self.id, self.slug])

  # bookmarks/images/templates/images/image/detail.html
  {% extends "base.html" %}
  {% block title %}{{ image.title }}{% endblock %}
  {% block content %}
    <h1>{{ image.title }}</h1>
    <img src="{{ image.image.url }}" class="image-detail">
    {% with total_likes=image.users_like.count %}
      <div class="image-info">
        <div>
          <span class="count">
            {{ total_likes }} like{{ total_likes|pluralize }}
          </span>
        </div>
        {{ image.description|linebreaks }}
      </div>
      <div class="image-likes">
        {% for user in image.users_like.all %}
          <div>
            {% if user.profile.photo %}
              <img src="{{ user.profile.photo.url }}">
            {% endif %}
            <p>{{ user.first_name }}</p>
          </div>
        {% empty %}
          Nobody likes this image yet.
        {% endfor %}
      </div>
    {% endwith %}
  {% endblock %}
  ```

- Whenever you need to repeat a query in your template, use the `{% with %}`
  template tag to prevent additional database queries.
- So now we need some AJAX to like and unlike images without reloading the
  page. We are going to use the newer JavaScript Fetch API.

  ```py
  # bookmarks/images/views.py
  from django.http import JsonResponse
  from django.views.decorators.http import require_POST
  @login_required
  @require_POST
  def image_like(request):
      image_id = request.POST.get("id")
      action = request.POST.get("action")
      if image_id and action:
          try:
              image = Image.objects.get(id=image_id)
              if action == "like":
                  image.users_like.add(request.user)
              else:
                  image.users_like.remove(request.user)
              return JsonResponse({"status": "ok"})
          except Image.DoesNotExist:
              pass
      return JsonResponse({"status": "error"})

  # bookmarks/images/urls.py
      path('like/', views.image_like, name='like')

  # bookmarks/account/templates/base.html
  # ...
    </div>
    <script 
      src="//cdn.jsdelivr.net/npm/js-cookie@3.0.5/dist/js.cookie.min.js">
    </script>
    <script>
      const csrftoken = Cookies.get('csrftoken');
      document.addEventListener('DOMContentLoaded', (event) => {
        {% block domready %}
        {% endblock %}
      })
    </script>
  </body>
  </html>

  # bookmarks/images/templates/images/image/detail.html
    {% with total_likes=image.users_like.count users_like=image.users_like.all %}
      <div class="image-info">
        <div>
          <span class="count">
            <span class="total">{{ total_likes }}</span>
            like{{ total_likes|pluralize }}
          </span>
          <a href="#" data-id="{{ image.id }}"
              data-action="{% if request.user in users_like %}un{% endif %}like"
              class="like button">
            {% if request.user not in users_like %}
              Like
            {% else %}
              Unlike
            {% endif %}
          </a>
        </div>
        {{ image.description|linebreaks }}
      </div>
      <div class="image-likes">
        {% for user in image.users_like.all %}
        # ...
  {% endblock %}

  {% block domready %}
    const url = '{% url "images:like" %}';
    var options = {
      method: 'POST',
      headers: {'X-CSRFToken': csrftoken},
      mode: 'same-origin'
    }
    document.querySelector('a.like')
            .addEventListener('click', function(e) {
      e.preventDefault();
      var likeButton = this;
      // add request body
      var formData = new FormData();
      formData.append('id', likeButton.dataset.id);
      formData.append('action', likeButton.dataset.action)
      options['body'] = formData;
      // send HTTP request
      fetch(url, options)
      .then(response => response.json())
      .then(data => {
        if (data['status'] === 'ok') {
          var previousAction = likeButton.dataset.action;
          // toggle button text and data-action
          var action = previousAction === 'like' ? 'unlike' : 'like';
          likeButton.dataset.action = action;
          likeButton.innerHTML = action;
          // update like count
          var likeCount = document.querySelector('span.count .total');
          var totalLikes = parseInt(likeCount.innerHTML);
          likeCount.innerHTML = previousAction === 'like' ? totalLikes + 1 : totalLikes - 1;
        }
      })
    });
  {% endblock %}
  ```

- We used `require_POST` for this. Django also supports `require_GET` and
  `require_http_methods` where you pass allowed methods as an argument.
- By adding the `domready` block to the `base.html` template, we can easily
  insert JavaScript code into any template that fires when the DOM is ready.
- Thumbnails come from the `easy-thumbnails` package. Install it with
  `python -m pip install easy-thumbnails==2.8.5`, add `easy_thumbnails` to
  `INSTALLED_APPS`, and run `python manage.py migrate`. Templates need
  `{% load thumbnail %}`, and the tag works two ways:
  - `{% thumbnail image.image 300x300 %}` outputs the thumbnail's URL right
    where it sits, so it can go straight into an `src` attribute.
  - Adding `as im` to the end outputs nothing and saves the thumbnail in a
    variable instead, so you can use `{{ im.url }}` (plus `im.width` and
    `im.height`) later. `list_images.html` in the next section is an
    example.
- And finally we add an infinite scrolling list view.

  ```py
  # bookmarks/images/views.py
  from django.core.paginator import EmptyPage, PageNotAnInteger, Paginator
  from django.http import HttpResponse, JsonResponse

  @login_required
  def image_list(request):
      images = Image.objects.all()
      paginator = Paginator(images, 8)
      page = request.GET.get('page')
      images_only = request.GET.get('images_only')
      try:
          images = paginator.page(page)
      except PageNotAnInteger:
          # If page is not an integer show the first page
          images = paginator.page(1)
      except EmptyPage:
          if images_only:
              # If AJAX request and page out of range return an empty page
              return HttpResponse('')
          # If page out of range return last page of results
          images = paginator.page(paginator.num_pages)
      if images_only:
          return render(
              request,
              'images/image/list_images.html',
              {'section': 'images', 'images': images}
          )
      return render(
          request,
          'images/image/list.html',
          {'section': 'images', 'images': images}
      )

  # bookmarks/images/urls.py
      path('', views.image_list, name='list'),

  # bookmarks/images/templates/images/image/list_images.html
  {% load thumbnail %}
  {% for image in images %}
    <div class="image">
      {% thumbnail image.image 300x300 crop="smart" as im %}
      <a href="{{ image.get_absolute_url }}">
        <img src="{{ im.url }}">
      </a>
      <div class="info">
        <a href="{{ image.get_absolute_url }}" class="title">
          {{ image.title }}
        </a>
      </div>
    </div>
  {% endfor %}

  # bookmarks/images/templates/images/image/list.html
  {% extends "base.html" %}
  {% block title %}Images bookmarked{% endblock %}
  {% block content %}
    <h1>Images bookmarked</h1>
    <div id="image-list">
      {% include "images/image/list_images.html" %}
    </div>
  {% endblock %}

  {% block domready %}
    var page = 1;
    var emptyPage = false;
    var blockRequest = false;
    window.addEventListener('scroll', function(e) {
      var margin = document.body.clientHeight - window.innerHeight - 200;
      if (window.pageYOffset > margin && !emptyPage && !blockRequest) {
        blockRequest = true;
        page += 1;
        fetch('?images_only=1&page=' + page)
        .then(response => response.text())
        .then(html => {
          if (html === '') {
            emptyPage = true;
          } else {
            var imageList = document.getElementById('image-list');
            imageList.insertAdjacentHTML('beforeEnd', html);
            blockRequest = false;
          }
        })
      }
    });
    // Launch scroll event
    const scrollEvent = new Event('scroll');
    window.dispatchEvent(scrollEvent);
  {% endblock %}
  ```

## Chapter 7 - Tracking User Actions

- The first task of this chapter is creating a follow system. The
  relationship between users is many-to-many where a user can follow multiple
  users and they can be followed by multiple users. Since we want to store
  additional information in this relationship, we will manually create a model
  rather than just using the intermediate tables Django gives us through
  `ManyToManyField`.

  ```py
  # bookmarks/account/models.py
  from django.contrib.auth import get_user_model
  
  class Contact(models.Model):
      user_from = models.ForeignKey(
          settings.AUTH_USER_MODEL, 
          related_name="rel_from_set", 
          on_delete=models.CASCADE
      )
      user_to = models.ForeignKey(
          settings.AUTH_USER_MODEL, 
          related_name="rel_to_set", 
          on_delete=models.CASCADE
      )
      created = models.DateTimeField(auto_now_add=True)

      class Meta:
          indexes = [
              models.Index(fields=["-created"]),
          ]
          ordering = ["-created"]

      def __str__(self):
          return f"{self.user_from} follows {self.user_to}"

  # Add the following field to User dynamically
  user_model = get_user_model()
  user_model.add_to_class(
      'following',
      models.ManyToManyField(
          'self',
          through=Contact,
          related_name='followers',
          symmetrical=False
      )
  )
  ```

- We need to specify `symmetrical=False` or else a `ManyToManyField` to `self`
  defaults to a symmetrical relationship.
- The book says that with an intermediate model, related manager methods like
  `add()`, `create()`, and `remove()` are disabled, but that stopped being
  true in Django 2.2. They work now, and a `through_defaults` argument fills
  in the intermediate model's extra fields. `Contact`'s only extra field,
  `created`, fills itself in, so `request.user.following.add(other_user)`
  works as-is.
- So we need a way to list users and see user details:

  ```py
  # bookmarks/account/views.py
  from django.contrib.auth import authenticate, get_user_model, login
  from django.shortcuts import get_object_or_404, render

  User = get_user_model()

  @login_required
  def user_list(request):
      users = User.objects.filter(is_active=True, is_staff=False)
      return render(
          request, 
          "account/user/list.html", 
          {"section": "people", "users": users}
      )

  @login_required
  def user_detail(request, username):
      user = get_object_or_404(User, username=username, is_active=True)
      return render(
          request,
          'account/user/detail.html',
          {'section': 'people', 'user': user}
      )

  # bookmarks/account/urls.py
      path('users/', views.user_list, name='user_list'),
      path('users/<username>/', views.user_detail, name='user_detail'),

  # bookmarks/bookmarks/settings.py
  from django.urls import reverse_lazy
  ABSOLUTE_URL_OVERRIDES = {
      'auth.user': lambda u: reverse_lazy('user_detail', args=[u.username])
  }

  # bookmarks/account/templates/account/user/list.html
  {% extends "base.html" %}
  {% load static thumbnail %}
  {% block title %}People{% endblock %}
  {% block content %}
    <h1>People</h1>
    <div id="people-list">
      {% for user in users %}
        <div class="user">
          <a href="{{ user.get_absolute_url }}">
            {% if user.profile.photo %}
              <img src="{% thumbnail user.profile.photo 180x180 %}">
            {% else %}
              <img src="{% static 'images/default-avatar.svg' %}" alt="">
            {% endif %}
          </a>
          <div class="info">
            <a href="{{ user.get_absolute_url }}" class="title">
              {{ user.get_full_name }}
            </a>
          </div>
        </div>
      {% endfor %}
    </div>
  {% endblock %}

  # bookmarks/account/templates/account/user/detail.html
  {% extends "base.html" %}
  {% load static thumbnail %}
  {% block title %}{{ user.get_full_name }}{% endblock %}
  {% block content %}
    <h1>{{ user.get_full_name }}</h1>
    <div class="profile-info">
      {% if user.profile.photo %}
        <img src="{% thumbnail user.profile.photo 180x180 %}" 
            class="user-detail">
      {% else %}
         <img src="{% static 'images/default-avatar.svg' %}" alt="" 
            class="user-detail">
      {% endif %}
    </div>
    {% with total_followers=user.followers.count %}
      <span class="count">
        <span class="total">{{ total_followers }}</span>
        follower{{ total_followers|pluralize }}
      </span>
      <a href="#" data-id="{{ user.id }}"
          data-action="{% if request.user in user.followers.all %}un{% endif %}follow" 
          class="follow button">
        {% if request.user not in user.followers.all %}
          Follow
        {% else %}
          Unfollow
        {% endif %}
      </a>
      <div id="image-list" class="image-container">
        {% include "images/image/list_images.html" with images=user.images_created.all %}
      </div>
    {% endwith %}
  {% endblock %}

  # bookmarks/account/templates/base.html
          <li {% if section == "people" %}class="selected"{% endif %}>
            <a href="{% url "user_list" %}">People</a>
          </li>
  ```

- By putting `ABSOLUTE_URL_OVERRIDES` in `settings.py` you have Django
  dynamically add `get_absolute_url()` to the listed models. We do this so
  we don't need a custom `User` class since it is tough to migrate to after
  starting with the regular `User` from `auth`.
- So now let's wire up follow and unfollow:

  ```py
  # bookmarks/account/views.py
  from django.http import HttpResponse, JsonResponse
  from django.views.decorators.http import require_POST

  from .models import Contact

  @require_POST
  @login_required
  def user_follow(request):
      user_id = request.POST.get('id')
      action = request.POST.get('action')
      if user_id and action:
          try:
              user = User.objects.get(id=user_id)
              if action == 'follow':
                  Contact.objects.get_or_create(
                      user_from=request.user,
                      user_to=user
                  )
              else:
                  Contact.objects.filter(
                      user_from=request.user,
                      user_to=user
                  ).delete()
              return JsonResponse({'status': 'ok'})
          except User.DoesNotExist:
              return JsonResponse({'status': 'error'})
      return JsonResponse({'status': 'error'})

  # bookmarks/account/urls.py
      path("users/follow/", views.user_follow, name='user_follow'),

  # bookmarks/account/templates/account/user/detail.html
  {% block domready %}
    const url = '{% url "user_follow" %}';
    var options = {
      method: 'POST',
      headers: {'X-CSRFToken': csrftoken},
      mode: 'same-origin'
    }
    document.querySelector('a.follow')
            .addEventListener('click', function(e) {
      e.preventDefault();
      var followButton = this;
      // add request body
      var formData = new FormData();
      formData.append('id', followButton.dataset.id);
      formData.append('action', followButton.dataset.action);
      options['body'] = formData;
      // send HTTP request
      fetch(url, options)
      .then(response => response.json())
      .then(data => {
        if (data['status'] === 'ok')
        {
          var previousAction = followButton.dataset.action;

          // toggle button text and data-action
          var action = previousAction === 'follow' ? 'unfollow' : 'follow';
          followButton.dataset.action = action;
          followButton.innerHTML = action;
 
          // update follower count
          var followerCount = document.querySelector('span.count .total');
          var totalFollowers = parseInt(followerCount.innerHTML);
          followerCount.innerHTML = previousAction === 'follow' ? totalFollowers + 1 : totalFollowers - 1;
        }
      })
    });
  {% endblock %}
  ```

- Note that you need to put `"users/follow/"` before
  `"users/<username>/"` or else it will match the latter.
- Next we are going to `manage.py startapp actions` and add it to
  INSTALLED_APPS. This is going to handle our activity stream.

  ```py
  # bookmarks/actions/models.py
  from django.conf import settings
  from django.db import models

  class Action(models.Model):
      user = models.ForeignKey(
          settings.AUTH_USER_MODEL,
          related_name='actions',
          on_delete=models.CASCADE
      )
      verb = models.CharField(max_length=255)
      created = models.DateTimeField(auto_now_add=True)
      class Meta:
          indexes = [
              models.Index(fields=['-created']),
          ]
          ordering = ['-created']
  ```

- To say "user X followed user Y" or "user X bookmarked image Y" we need a
  way to specify a target of an existing model but not one specific model.
  This is what the Django `contenttypes` framework can help us do.
  `ContentType` has `app_label`, `model`, and `name` fields, and
  `django.contrib.contenttypes` is in `INSTALLED_APPS` by default after
  `startproject`. It is common to obtain the `ContentType` object for a
  particular model as follows:

  ```py
  >>> from django.contrib.contenttypes.models import ContentType
  >>> ContentType.objects.get(app_label='images', model='image')

  >>> from images.models import Image
  >>> ContentType.objects.get_for_model(Image)
  ```

- To set up a generic relation to another model, you will need a `ForeignKey`
  field to `ContentType`, a field to store the primary key of the related
  object (usually a `PositiveIntegerField`), and a field to define and manage
  the generic relation using the two previous fields. The `contenttypes`
  framework offers a `GenericForeignKey` field for this purpose.

  ```py
  from django.conf import settings
  from django.contrib.contenttypes.fields import GenericForeignKey
  from django.contrib.contenttypes.models import ContentType
  from django.db import models


  class Action(models.Model):
      user = models.ForeignKey(
          settings.AUTH_USER_MODEL, related_name="actions", on_delete=models.CASCADE
      )
      verb = models.CharField(max_length=255)
      created = models.DateTimeField(auto_now_add=True)
      target_ct = models.ForeignKey(
          ContentType,
          blank=True,
          null=True,
          related_name='target_obj',
          on_delete=models.CASCADE
      )
      target_id = models.PositiveIntegerField(null=True, blank=True)
      target = GenericForeignKey('target_ct', 'target_id')

      class Meta:
          indexes = [
              models.Index(fields=["-created"]),
              models.Index(fields=['target_ct', 'target_id'])
          ]
          ordering = ["-created"]
  ```

- So now `Action` has `target_ct` to point to the `ContentType`, `target_id`
  for the primary key of the related object, and `target` to combine the 
  previous two fields. A `GenericForeignKey` isn't a column in the database;
  it's a convenience accessor that reads and writes the other two fields for
  you. You can't `filter` by the virtual `target`, but you can read and assign
  it. We made `target_ct` and `target_id` nullable so a target is optional.
- We aren't using it now, but `limit_choices_to` attribute of `ForeignKey`
  fields can be handy to restrict `target_ct` to specific models. It allows you
  to restrict the content of `ForeignKey` fields to a specific set of values.
- We also want to add `Action` to the admin site and create our first
  utility in `utils.py`: `create_action`.

  ```py
  # bookmarks/actions/admin.py
  from django.contrib import admin

  from .models import Action

  @admin.register(Action)
  class ActionAdmin(admin.ModelAdmin):
      list_display = ["user", "verb", "target", "created"]
      list_filter = ["created"]
      search_fields = ["verb"]

  # bookmarks/actions/utils.py
  from django.contrib.contenttypes.models import ContentType

  from .models import Action

  def create_action(user, verb, target=None):
      action = Action(user=user, verb=verb, target=target)
      action.save()
  ```

- But that was just a first draft of `create_action`. We want to prevent
  creating duplicate actions, so we're going to need more code.

  ```py
  import datetime
  from django.contrib.contenttypes.models import ContentType
  from django.utils import timezone

  from .models import Action

  def create_action(user, verb, target=None):
      # Check for any similar action made in the last minute
      now = timezone.now()
      last_minute = now - datetime.timedelta(seconds=60)
      similar_actions = Action.objects.filter(
          user_id=user.id, verb=verb, created__gte=last_minute
      )
      if target:
          target_ct = ContentType.objects.get_for_model(target)
          similar_actions = similar_actions.filter(
              target_ct=target_ct, target_id=target.id
          )
      if not similar_actions:
          action = Action(user=user, verb=verb, target=target)
          action.save()
          return True
      return False
  ```

- So we now have a flexible `Action` model that can relate to many other
  tables. What are we going to use it to store?
  - A user bookmarks an image
  - A user likes an image
  - A user creates an account
  - A user starts following another user

  ```py
  # bookmarks/images/views.py
  from actions.utils import create_action

  @login_required
  def image_create(request):

      if request.method == "POST":
          form = ImageCreateForm(data=request.POST)
          if form.is_valid():
              cd = form.cleaned_data
              new_image = form.save(commit=False)
              new_image.user = request.user
              new_image.save()
              create_action(request.user, 'bookmarked image', new_image)
              messages.success(request, "Image added successfully")
              return redirect(new_image.get_absolute_url())
      else:
          form = ImageCreateForm(data=request.GET)
      return render(
          request, "images/image/create.html", {"section": "images", "form": form}
      )
  ```

- And we make similar changes to `image_like` in `images/views.py` and both 
  `register` and `user_follow` in `account/views.py`. Then we want to modify
  the dashboard to show actions of users we follow:

  ```py
  from actions.models import Action

  @login_required
  def dashboard(request):
      # Display all actions by default
      actions = Action.objects.exclude(user=request.user)
      following_ids = request.user.following.values_list('id', flat=True)
      if following_ids:
          actions = actions.filter(user_id__in=following_ids)
      actions = actions[:10]
      return render(request, "account/dashboard.html", 
                    {"section": "dashboard", 'actions': actions})
  ```

- This seems nice, but has the drawback that we need to query for the `User`
  and `Profile`. It seems every time we want to work with an `Action`, we will
  want the related `User` and `Profile` objects. Django makes this easy to
  manage by retrieving related objects at the same time with 
  `select_related()`.
  `select_related()` is for `ForeignKey` and `OneToOne` fields. It works
  by joining the tables and including the fields of the related object.
  Replace `actions = actions[:10]` above with the following:

  ```py
      actions = actions.select_related("user", "user__profile")[:10]
  ```

- If you call `select_related()` without arguments, it will retrieve objects
  from all `ForeignKey` relationships, but it is good practice to always
  limit your `select_related()` queries to the relationships that will be
  accessed afterward.
- `select_related()` does not work for `ManyToMany` or reverse `ForeignKey`
  fields, so we also have `prefetch_related()` that works for many-to-many
  and many-to-one relationships in addition to those supported by
  `select_related()`. This method also supports prefetching of 
  `GenericRelation` or `GenericForeignKey`. So let's replace the same line
  to use it:

  ```py
  actions = actions.select_related("user", "user__profile").prefetch_related(
      "target"
  )[:10]
  ```

- And now we just need a template:

  ```py
  # actions/templates/actions/action/detail.html
  {% load static thumbnail %}
  {% with user=action.user profile=action.user.profile %}
  <div class="action">
    <div class="images">
      {% if profile.photo %}
        {% thumbnail user.profile.photo "80x80" crop="100%" as im %}
        <a href="{{ user.get_absolute_url }}">
          <img src="{{ im.url }}" alt="{{ user.get_full_name }}"
            class="item-img">
        </a>
      {% else %}
        <a href="{{ user.get_absolute_url }}">
          <img src="{% static 'images/default-avatar.svg' %}" 
            alt="{{ user.get_full_name }}"
            class="item-img" width="80" height="80">
        </a>
      {% endif %}
      {% if action.target %}
        {% with target=action.target %}
          {% if target.image %}
            {% thumbnail target.image "80x80" crop="100%" as im %}
            <a href="{{ target.get_absolute_url }}">
              <img src="{{ im.url }}" class="item-img">
            </a>
          {% elif target.profile %}
            <a href="{{ target.get_absolute_url }}">
              {% if target.profile.photo %}
                {% thumbnail target.profile.photo "80x80" crop="100%" as im %}
                <img src="{{ im.url }}" alt="{{ target.get_full_name }}"
                  class="item-img">
              {% else %}
                <img src="{% static 'images/default-avatar.svg' %}"
                  alt="{{ target.get_full_name }}"
                  class="item-img" width="80" height="80">
              {% endif %}
            </a>
          {% endif %}
        {% endwith %}
      {% endif %}
    </div>
    <div class="info">
      <p>
        <span class="date">{{ action.created|timesince }} ago</span>
        <br />
        <a href="{{ user.get_absolute_url }}">
          {{ user.first_name }}
        </a>
        {{ action.verb }}
        {% if action.target %}
          {% with target=action.target %}
            <a href="{{ target.get_absolute_url }}">
              {% if target.profile %}{{ target.first_name }}{% else %}{{ target }}{% endif %}
            </a>
          {% endwith %}
        {% endif %}
      </p>
    </div>
  </div>
  {% endwith %}

  # account/templates/account/dashboard.html
  # ...
    <h2>What's happening</h2>
    <div id="action-list">
      {% for action in actions %}
        {% include "actions/action/detail.html" %}
      {% endfor %}
    </div>
  {% endblock %}
  ```

- Next we plan to denormalize data from our `Image` model and use Django signals
  to keep the data updated. Denormalization can optimize read performance.
  Signals allow receiver functions to get notified when certain actions occur
  and are very useful when you need your code to do something every time
  something else happens. We could clearly retrieve our images ordered by the
  count of `users_like`, but it would be slow. So we plan to store
  `total_likes` in the database as a field and update it via signals.
  Denormalizing counts is useful when you want to filter or order QuerySets by
  them.
- Some of the useful signals included in `django.db.models.signals` are
  `pre_save`, `post_save`, `pre_delete`, `post_delete`, and `m2m_changed` (for
  when a `ManyToManyField` on a model is changed.)
- When you declare a `receiver`, you need to import the `signals` module of your
  application inside the `ready()` method of the application configuration
  class.

  ```py
  # bookmarks/images/models.py
  class Image(models.Model):
      # ...
      users_like = models.ManyToManyField(
          settings.AUTH_USER_MODEL, related_name="images_liked", blank=True
      )
      total_likes = models.PositiveIntegerField(default=0)

      class Meta:
          indexes = [
              models.Index(fields=["-created"]),
              models.Index(fields=['-total_likes']),
          ]
          ordering = ["-created"]

  # bookmarks/images/signals.py
  from django.db.models.signals import m2m_changed
  from django.dispatch import receiver

  from .models import Image

  @receiver(m2m_changed, sender=Image.users_like.through)
  def users_like_changed(sender, instance, **kwargs):
      instance.total_likes = instance.users_like.count()
      instance.save()

  # bookmarks/images/apps.py
  from django.apps import AppConfig

  class ImagesConfig(AppConfig):
      default_auto_field = "django.db.models.BigAutoField"
      name = "images"

      def ready(self):
          # import signal handlers
          import images.signals

  # ./manage.py shell
  >>> from images.models import Image
  >>> for image in Image.objects.all():
  ...     image.total_likes = image.users_like.count()
  ...     image.save()
  ```

- Django Debug Toolbar provides extra debugging information and can be installed
  via `pip install django-debug-toolbar==4.3.0` then adding `debug_toolbar` to 
  `INSTALLED_APPS` and `debug_toolbar.middleware.DebugToolbarMiddleware` to
  `MIDDLEWARE` in `bookmarks/settings.py`. It needs to be placed above any
  middleware except middleware that encode the response's content such as
  `GZipMiddleware`. You also need to add `INTERNAL_IPS = [ "127.0.0.1", ]` to 
  the bottom of `settings.py`. `bookmarks/urls.py` also needs the pattern
  `path("__debug__/", include("debug_toolbar.urls")),`.
- In addition to a toolbar, the Django Debug Toolbar provides a
  `manage.py debugsqlshell` that is like the normal `shell` but outputs SQL for
  queries performed with the Django ORM.
- Redis is an advanced key/value database that we are going to use to provide
  low-latency and high-throughput data access to counts of image views. We will
  run Redis through Docker, so first `docker pull redis:7.2.4` then
  `docker run -it --rm --name redis -p 6379:6379 redis:7.2.4`. In the `docker`
  command `-it` tells Docker to take you inside the container for interactive
  input, `--rm` tells Docker to automatically clean up the container and remove
  the file system when the container exits, `--name` says to assign it the name
  `redis`, and `-p` says to publish port 6379 to host interface port 6379. You
  can run the Redis client in another terminal with `docker exec -it redis sh`
  then running `redis-cli` at the prompt. Some useful commands are `SET`, `GET`,
  `DEL`, `EXPIRE` which allows you to set the time-to-live in seconds, and 
  `EXPIREAT` which takes a Unix timestamp. Key expiration is useful for caching.
  `EXISTS` allows you to test for existence. More commands are available at
  [Redis commands](https://redis.io/commands/).
- To use Redis from python, we need to `pip install redis==5.0.4`. You can use
  Redis at the shell with `./manage.py shell`, `import redis`,
  `r = redis.Redis(host='localhost', port=6379, db=0)` then
  `r.set('foo', 'bar')` and `r.get('foo')`. Redis databases are numbered rather
  than named and start with 0. There are 16 by default (0 through 15) unless
  you change this in `redis.conf`. For Django, we'll put the Redis settings in 
  `bookmarks/settings.py`:

  ```py
  # bookmarks/bookmarks/settings.py 
  REDIS_HOST = "localhost"
  REDIS_PORT = 6379
  REDIS_DB = 0
  ```

- Let's say we wanted to count image views. With SQL this would involve an
  update every time an image is displayed. It is much less overhead to do it
  in Redis where the count is stored in memory.

  ```py
  # bookmarks/images/views.py
  import redis
  from django.conf import settings

  # connect to redis
  r = redis.Redis(
      host=settings.REDIS_HOST,
      port=settings.REDIS_PORT,
      db=settings.REDIS_DB
  )

  def image_detail(request, id, slug):
      image = get_object_or_404(Image, id=id, slug=slug)
      total_views = r.incr(f"image:{image.id}:views")
      return render(
          request, 
          "images/image/detail.html", 
          {
              "section": "images", 
              "image": image,
              "total_views": total_views
          }
      )

  # bookmarks/images/templates/images/image/detail.html
      <div class="image-info">
        <div>
          <span class="count">
            <span class="total">{{ total_likes }}</span>
            like{{ total_likes|pluralize }}
          </span>
          <span class="count">
            {{ total_views }} view{{ total_views|pluralize }}
          </span>
          <a href="#" data-id="{{ image.id }}"
              data-action="{% if request.user in users_like %}un{% endif %}like"
              class="like button">
            {% if request.user not in users_like %}
              Like
            {% else %}
              Unlike
            {% endif %}
          </a>
        </div>
        {{ image.description|linebreaks }}
      </div>
  ```

- `incr()` adds 1 to a key's value (starting from 0 if the key doesn't exist
  yet) and returns the new value.
- The convention for naming Redis keys is to use a colon sign as a separator for
  creating namespaced keys such as `object-type:id:field`, for example
  `image:33:views`.
- Redis already stores our view count, so we intend to make it store a ranking
  of the most viewed images on the platform using Redis sorted sets. A sorted
  set is a non-repeating collection of strings in which every member is
  associated with a score and items are sorted by their score.

  ```py
  # bookmarks/images/views.py
  def image_detail(request, id, slug):
      image = get_object_or_404(Image, id=id, slug=slug)
      total_views = r.incr(f"image:{image.id}:views")
      r.zincrby('image:ranking', 1, image.id)
      return render(
          request,
          "images/image/detail.html",
          {"section": "images", "image": image, "total_views": total_views},
      )

  @login_required
  def image_ranking(request):
      image_ranking = r.zrange("image:ranking", 0, -1, desc=True)[:10]
      image_ranking_ids = [int(id) for id in image_ranking]
      most_viewed = list(Image.objects.filter(id__in=image_ranking_ids))
      most_viewed.sort(key=lambda x: image_ranking_ids.index(x.id))
      return render(
          request,
          "images/image/ranking.html",
          {"section": "images", "most_viewed": most_viewed},
      )

  # bookmarks/images/templates/images/image/ranking.html
  {% extends "base.html" %}
  {% block title %}Images ranking{% endblock %}
  {% block content %}
    <h1>Images ranking</h1>
    <ol>
      {% for image in most_viewed %}
        <li>
          <a href="{{ image.get_absolute_url }}">{{ image.title }}</a>
        </li>
      {% endfor %}
    </ol>
  {% endblock %}

  # bookmarks/images/urls.py
      path("ranking/", views.image_ranking, name="ranking"),
  ```

- `zincrby()` stores image views in a sorted set with the `image:ranking` key.
  It stores the image `id` and adds `1` to its score.
- `zrange()` returns members of the sorted set by position in the sort order,
  not by score. `0` is the first position and `-1` is the last, as in Python
  slicing, so `0, -1` returns every element. `desc=True` orders them from
  highest score to lowest. Then we slice the results to the first 10. Passing
  `0, 9` instead would have Redis return only the top 10.
- Note that Redis dumps its data to `/data`, but since we started it
  with `--rm` the disk won't be saved. If we want to run Redis and keep the dump
  we `docker run -d --name redis -p 6379:6379 -v redis-data:/data redis:7.2.4`.
  and from then on just `docker stop redis` and `docker start redis`.
- I also followed the AI prompt to remove the logic of creating a `Profile`
  manually and instead create a `Profile` on `post_save` of the `User` model.
  That replaces both `Profile.objects.create()` in `register` and the
  `create_profile` step in `SOCIAL_AUTH_PIPELINE`, and it also covers users
  made with `createsuperuser` or the admin. `raw` is `True` while `loaddata`
  runs, and skipping it keeps a fixture's own `Profile` rows from colliding
  with ones the signal would create.

  ```py
  # bookmarks/account/signals.py
  from django.contrib.auth import get_user_model
  from django.db.models.signals import post_save
  from django.dispatch import receiver

  from .models import Profile


  @receiver(post_save, sender=get_user_model())
  def create_profile(sender, instance, created, raw=False, **kwargs):
      if created and not raw:
          Profile.objects.get_or_create(user=instance)

  # bookmarks/account/apps.py
  class AccountConfig(AppConfig):
      default_auto_field = "django.db.models.BigAutoField"
      name = "account"

      def ready(self):
          import account.signals  # noqa: F401
  ```

## Chapter 8 - Building an Online Shop

- New project, so we startproject and startapp then start defining out model:

  ```py
  # myshop/shop/models.py
  from django.db import models

  class Category(models.Model):
      name = models.CharField(max_length=200)
      slug = models.SlugField(max_length=200, unique=True)

      class Meta:
          ordering = ["name"]
          indexes = [
              models.Index(fields=["name"]),
          ]
          verbose_name = "category"
          verbose_name_plural = "categories"

      def __str__(self):
          return self.name


  class Product(models.Model):
      category = models.ForeignKey(
          Category, related_name="products", on_delete=models.CASCADE
      )
      name = models.CharField(max_length=200)
      slug = models.SlugField(max_length=200)
      image = models.ImageField(upload_to="products/%Y/%m/%d", blank=True)
      description = models.TextField(blank=True)
      price = models.DecimalField(max_digits=10, decimal_places=2)
      available = models.BooleanField(default=True)
      created = models.DateTimeField(auto_now_add=True)
      updated = models.DateTimeField(auto_now=True)

      class Meta:
          ordering = ["name"]
          indexes = [
              models.Index(fields=["id", "slug"]),
              models.Index(fields=["name"]),
              models.Index(fields=["-created"]),
          ]

      def __str__(self):
          return self.name

  # myshop/shop/admin.py
  from django.contrib import admin

  from .models import Category, Product

  @admin.register(Category)
  class CategoryAdmin(admin.ModelAdmin):
      list_display = ["name", "slug"]
      prepopulated_fields = {"slug": ("name",)}


  @admin.register(Product)
  class ProductAdmin(admin.ModelAdmin):
      list_display = ["name", "slug", "price", "available", "created", "updated"]
      list_filter = ["available", "created", "updated"]
      list_editable = ["price", "available"]
      prepopulated_fields = {"slug": ("name",)}
  ```

- Remembering that defining a field as unique automatically generates an index
  for it.
- Always use `DecimalField` and not `FloatField` when dealing with money.

  ```py
  # myshop/shop/views.py
  from django.shortcuts import get_object_or_404, render

  from .models import Category, Product

  def product_list(request, category_slug=None):
      category = None
      categories = Category.objects.all()
      products = Product.objects.filter(available=True)
      if category_slug:
          category = get_object_or_404(Category, slug=category_slug)
          products = products.filter(category=category)
      return render(
          request,
          "shop/product/list.html",
          {
              "category": category, 
              "categories": categories, 
              "products": products},
      )

  def product_detail(request, id, slug):
      product = get_object_or_404(Product, id=id, slug=slug, available=True)
      return render(request, "shop/product/detail.html", {"product": product})

  # myshop/shop/urls.py
  from django.urls import path

  from . import views

  app_name = "shop"
  urlpatterns = [
      path("", views.product_list, name="product_list"),
      path(
          "<slug:category_slug>/", 
          views.product_list, 
          name="product_list_by_category"),
      path(
          "<int:id>/<slug:slug>",
          views.product_detail,
          name="product_detail"
      )
  ]

  # myshop/myshop/urls.py
  from django.contrib import admin
  from django.urls import path

  urlpatterns = [
      path("admin/", admin.site.urls),
      path("", include("shop.urls", namespace="shop"))
  ]

  # myshop/shop/models.py
  from django.db import models
  from django.urls import reverse

  class Category(models.Model):
      # ...
      def get_absolute_url(self):
          return reverse("shop:product_list_by_category", args=[self.slug])

  class Product(models.Model):
      # ...
      def get_absolute_url(self):
          return reverse("shop:product_detail", args=[self.id, self.slug])

  # myshop/shop/templates/shop/base.html
  {% load static %}
  <!DOCTYPE html>
  <html>
    <head>
      <meta charset="utf-8" />
      <title>{% block title %}My shop{% endblock %}</title>
      <link href="{% static "css/base.css" %}" rel="stylesheet">
    </head>
    <body>
      <div id="header">
        <a href="/" class="logo">My shop</a>
      </div>
      <div id="subheader">
        <div class="cart">
          Your cart is empty.
        </div>
      </div>
      <div id="content">
        {% block content %}
        {% endblock %}
      </div>
    </body>
  </html>

  # myshop/shop/templates/shop/product/list.html
  {% extends "shop/base.html" %}
  {% load static %}
  {% block title %}
    {% if category %}{{ category.name }}{% else %}Products{% endif %}
  {% endblock %}
  {% block content %}
    <div id="sidebar">
      <h3>Categories</h3>
      <ul>
        <li {% if not category %}class="selected"{% endif %}>
          <a href="{% url "shop:product_list" %}">All</a>
        </li>
        {% for c in categories %}
          <li {% if category.slug == c.slug %}class="selected"{% endif %}>
            <a href="{{ c.get_absolute_url }}">{{ c.name }}</a>
          </li>
        {% endfor %}
      </ul>
    </div>
    <div id="main" class="product-list">
      <h1>{% if category %}{{ category.name }}{% else %}Products{% endif %}</h1>
      {% for product in products %}
        <div class="item">
          <a href="{{ product.get_absolute_url }}">
            <img src="{% if product.image %}{{ product.image.url }}{% else %}{% static "img/no_image.png" %}{% endif %}">
          </a>
          <a href="{{ product.get_absolute_url }}">{{ product.name }}</a>
          <br>
            ${{ product.price }}
        </div>
      {% endfor %}
    </div>
  {% endblock %}

  # myshop/shop/templates/shop/product/detail.html
  {% extends "shop/base.html" %}
  {% load static %}
  {% block title %}
    {{ product.name }}
  {% endblock %}
  {% block content %}
    <div class="product-detail">
      <img src="{% if product.image %}{{ product.image.url }}{% else %}{% static "img/no_image.png" %}{% endif %}">
      <h1>{{ product.name }}</h1>
      <h2>
        <a href="{{ product.category.get_absolute_url }}">
          {{ product.category }}
        </a>
      </h2>
      <p class="price">${{ product.price }}</p>
      {{ product.description|linebreaks }}
    </div>
  {% endblock %}

  # myshop/myshop/settings.py
  MEDIA_URL = "media/"
  MEDIA_ROOT = BASE_DIR / "media"

  # myshop/myshop/urls.py
  from django.conf import settings
  from django.conf.urls.static import static
  from django.contrib import admin
  from django.urls import include, path

  urlpatterns = [
      path("admin/", admin.site.urls),
      path("", include("shop.urls", namespace="shop")),
  ]

  if settings.DEBUG:
      urlpatterns += static(
          settings.MEDIA_URL, document_root=settings.MEDIA_ROOT
      )
  ```

- The Django session framework supports anonymous and user sessions and allows
  you to store arbitrary data for each visitor. Session data is stored server-
  side (by default in the database) and associated with the user by a session
  ID stored in cookies. The session middleware makes the current session
  available through the `request` object as `request.session`. You treat it like
  a Python dictionary like `request.session['foo'] = 'bar'`. You would retrieve
  foo's value with `request.session.get('foo')` or delete it via
  `del request.session['foo']`. When a user authenticates, their anonymous
  session is lost and a new session created. You would need to manually copy
  over data to preserve it after `login`.
- `SESSION_ENGINE` allows you to specify sessions as stored in the database (the
  default), file-based, cached (best performance but requires a CACHE), cached
  database sessions, and cookie-based sessions.
- Django uses JSON to serialize session data, and JSON only allows string key
  names.

  ```py
  # myshop/myshop/settings.py
  INSTALLED_APPS = [
      # ...
      "cart.apps.CartConfig",
      "shop.apps.ShopConfig",
  ]
  # ...
  CART_SESSION_ID = "cart"

  # myshop/cart/cart.py
  from decimal import Decimal

  from django.conf import settings
  from shop.models import Product

  class Cart:
      def __init__(self, request):
          """
          Initialize the cart.
          """
          self.session = request.session
          cart = self.session.get(settings.CART_SESSION_ID)
          if not cart:
              # save an empty cart in the session
              cart = self.session[settings.CART_SESSION_ID] = {}
          self.cart = cart

      def __iter__(self):
          """
          Iterate over the items in the cart and get the products
          from the database.
          """
          product_ids = self.cart.keys()
          products = Product.objects.filter(id__in=product_ids)
          cart = self.cart.copy()
          for product in products:
              cart[str(product.id)]['product'] = product
          for item in cart.values():
              item['price'] = Decimal(item['price'])
              item['total_price'] = item['price'] * item['quantity']
              yield item

      def __len__(self):
          """
          Count all items in the cart.
          """
          return sum(item['quantity'] for item in self.cart.values())

      def add(self, product, quantity=1, override_quantity=False):
          """
          Add a product to the cart or update its quantity.
          """
          product_id = str(product.id)
          if product_id not in self.cart:
              self.cart[product_id] = {'quantity': 0, 'price': str(product.price)}
          if override_quantity:
              self.cart[product_id]['quantity'] = quantity
          else:
              self.cart[product_id]['quantity'] += quantity
          self.save()

      def remove(self, product):
          """
          Remove a product from the cart.
          """
          product_id = str(product.id)
          if product_id in self.cart:
              del self.cart[product_id]
              self.save()

      def clear(self):
          # remove cart from session
          del self.session[settings.CART_SESSION_ID]
          self.save()

      def get_total_price(self):
          return sum(
              Decimal(item['price']) * item['quantity']
              for item in self.cart.values()
          )

      def save(self):
          # mark the session as "modified" to make sure it gets saved
          self.session.modified = True
  ```

- And we need forms, views, and templates to interact with our `Cart`:

  ```py
  # myshop/cart/forms.py
  from django import forms

  PRODUCT_QUANTITY_CHOICES = [(i, str(i)) for i in range(1, 21)]

  class CartAddProductForm(forms.Form):
      quantity = forms.TypedChoiceField(
          choices=PRODUCT_QUANTITY_CHOICES, 
          coerce=int
      )
      override = forms.BooleanField(
          required=False, initial=False, widget=forms.HiddenInput
      )

  # myshop/cart/views.py
  from django.shortcuts import get_object_or_404, redirect, render
  from django.views.decorators.http import require_POST
  from shop.models import Product

  from .cart import Cart
  from .forms import CartAddProductForm

  @require_POST
  def cart_add(request, product_id):
      cart = Cart(request)
      product = get_object_or_404(Product, id=product_id)
      form = CartAddProductForm(request.POST)
      if form.is_valid():
          cd = form.cleaned_data
          cart.add(
              product=product,
              quantity=cd['quantity'],
              override_quantity=cd['override']
          )
      return redirect('cart:cart_detail')

  @require_POST
  def cart_remove(request, product_id):
      cart = Cart(request)
      product = get_object_or_404(Product, id=product_id)
      cart.remove(product)
      return redirect("cart:cart_detail")

  def cart_detail(request):
      cart = Cart(request)
      return render(request, 'cart/detail.html', {'cart': cart})

  # myshop/cart/templates/cart/detail.html
  {% extends "shop/base.html" %}
  {% load static %}
  {% block title %}
    Your shopping cart
  {% endblock %}
  {% block content %}
    <h1>Your shopping cart</h1>
    <table class="cart">
      <thead>
        <tr>
          <th>Image</th>
          <th>Product</th>
          <th>Quantity</th>
          <th>Remove</th>
          <th>Unit price</th>
          <th>Price</th>
        </tr>
      </thead>
      <tbody>
        {% for item in cart %}
          {% with product=item.product %}
            <tr>
              <td>
                <a href="{{ product.get_absolute_url }}">
                  <img src="{% if product.image %}{{ product.image.url }}"
                  {% else %}{% static "img/no_image.png" %}{% endif %}">
                </a>
              </td>
              <td>{{ product.name }}</td>
              <td>{{ item.quantity }}</td>
              <td>
                <form action="{% url "cart:cart_remove" product.id %}" method="post">
                  <input type="submit" value="Remove">
                  {% csrf_token %}
                </form>
              </td>
              <td class="num">${{ item.price }}</td>
              <td class="num">${{ item.total_price }}</td>
            </tr>
          {% endwith %}
        {% endfor %}
        <tr class="total">
          <td>Total</td>
          <td colspan="4"></td>
          <td class="num">${{ cart.get_total_price }}</td>
        </tr>
      </tbody>
    </table>
    <p class="text-right">
      <a href="{% url "shop:product_list" %}" class="button light">Continue shopping</a>
      <a href="#" class="button">Checkout</a>
    </p>
  {% endblock %}

  # myshop/cart/urls.py
  from django.urls import path

  from . import views

  app_name = "cart"
  urlpatterns = [
      path("", views.cart_detail, name="cart_detail"),
      path("add/<int:product_id>/", views.cart_add, name="cart_add"),
      path("remove/<int:product_id/>", views.cart_remove, name="cart_remove"),
  ]

  # myshop/myshop/urls.py
      path("cart/", include("cart.urls", namespace="cart")),
      path("", include("shop.urls", namespace="shop")),

  # myshop/shop/views.py
  from cart.forms import CartAddProductForm
  # ...
  def product_detail(request, id, slug):
      product = get_object_or_404(Product, id=id, slug=slug, available=True)
      cart_product_form = CartAddProductForm()
      return render(
          request, 
          "shop/product/detail.html", 
          {"product": product, "cart_product_form": cart_product_form}
      )

  # myshop/shop/templates/shop/product.detail.html
  # ...
      <p class="price">${{ product.price }}</p>
      <form action="{% url "cart:cart_add" product.id %}" method="post">
        {{ cart_product_form }}
        {% csrf_token %}
        <input type="submit" value="Add to cart">
      </form>
      {{ product.description|linebreaks }}
  # ...
  ```

- Make sure to include "cart/" before "" for shop, since it is more restrictive.
- It looks nice but we want to be able to override quantity before placing an
  order:

  ```py
  # myshop/cart/views.py
  def cart_detail(request):
      cart = Cart(request)
      for item in cart:
          item["update_quantity_form"] = CartAddProductForm(
              initial={"quantity": item["quantity"], "override": True}
          )
      return render(request, "cart/detail.html", {"cart": cart})

  # myshop/cart/templates/cart/detail.html
  # find and replace this:
                <td>{{ item.quantity }}</td>
  # with
              <td>
                <form action="{% url "cart:cart_add" product.id %}" method="post">
                  {{ item.update_quantity_form.quantity }}
                  {{ item.update_quantity_form.override }}
                  <input type="submit" value="Update">
                  {% csrf_token %}
                </form>
              </td>
  ```

- A context processor is a Python function that takes the `request` object as an
  argument and returns a dictionary that gets added to the request context. They
  are used when you need to make something globally avilable to all templates.
  We want to add the current cart in the request context.

  ```py
  # myshop/cart/context_processors.py
  from .cart import Cart

  def cart(request):
      return {"cart": Cart(request)}

  # myshop/myshop/settings.py
  TEMPLATES = [
      {
          "BACKEND": "django.template.backends.django.DjangoTemplates",
          "DIRS": [],
          "APP_DIRS": True,
          "OPTIONS": {
              "context_processors": [
                  "django.template.context_processors.debug",
                  "django.template.context_processors.request",
                  "django.contrib.auth.context_processors.auth",
                  "django.contrib.messages.context_processors.messages",
                  "cart.context_processors.cart"
              ],
          },
      },
  ]

  # myshop/shop/templates/shop/base.html
  # find and replace
        <div class="cart">
          Your cart is empty.
        </div>
  # with
        <div class="cart">
          {% with total_items=cart|length %}
            {% if total_items > 0 %}
              Your cart:
              <a href="{% url "cart:cart_detail" %}">
                {{ total_items }} item{{ total_items|pluralize }},
                ${{ cart.get_total_price }}
              </a>
            {% else %}
              Your cart is empty.
            {% endif %}
          {% endwith %}
        </div>
  ```

- Context processors are executed in all the requests that use `RequestContext`.
  You might want to create a custom template tag instead of a context processor
  if your functionality is not needed in all templates, especially if it
  involves database queries.
- At this point we have finished the basic shopping site functionality of
  displaying products and adding quantities to a cart. Next we need a way for
  our customers to place an order. `./manage.py startapp orders`.

  ```py
  # myshop/orders/models.py
  from django.db import models

  class Order(models.Model):
      first_name = models.CharField(max_length=50)
      last_name = models.CharField(max_length=50)
      email = models.EmailField()
      address = models.CharField(max_length=250)
      postal_code = models.CharField(max_length=20)
      city = models.CharField(max_length=100)
      created = models.DateTimeField(auto_now_add=True)
      updated = models.DateTimeField(auto_now=True)
      paid = models.BooleanField(default=False)

      class Meta:
          ordering = ["-created"]
          indexes = [
              models.Index(fields=["-created"]),
          ]

      def __str__(self):
          return f"Order {self.id}"

      def get_total_cost(self):
          return sum(item.get_cost() for item in self.items.all())

  class OrderItem(models.Model):
      order = models.ForeignKey(Order, related_name="items", on_delete=models.CASCADE)
      product = models.ForeignKey(
          "shop.Product", related_name="order_items", on_delete=models.CASCADE
      )
      price = models.DecimalField(max_digits=10, decimal_places=2)
      quantity = models.PositiveIntegerField(default=1)

      def __str__(self):
          return str(self.id)

      def get_cost(self):
          return self.price * self.quantity

  # myshop/orders/admin.py
  from django.contrib import admin

  from .models import Order, OrderItem

  class OrderItemInline(admin.TabularInline):
      model = OrderItem
      raw_id_fields = ["product"]

  @admin.register(Order)
  class OrderAdmin(admin.ModelAdmin):
      list_display = [
          "id",
          "first_name",
          "last_name",
          "email",
          "address",
          "postal_code",
          "city",
          "paid",
          "created",
          "updated",
      ]
      list_filter = ["paid", "created", "updated"]
      inlines = [OrderItemInline]
  ```

- An inline lets you include a model on the same edit page as its related model.
- So the plan with orders is a three step process:
  1. Present a user with an order form to fill in their data.
  2. Create a new `Order` instance with the data entered, and create an 
     associated `OrderItem` instance for each item in the cart.
  3. Clear all the cart's contents and redirect the user to a success page.

  ```py
  # myshop/orders/forms.py
  from django import forms
  from .models import Order

  class OrderCreateForm(forms.ModelForm):
      class Meta:
          model = Order
          fields = [
              'first_name',
              'last_name',
              'email',
              'address',
              'postal_code',
              'city'
          ]

  # myshop/orders/views.py
  from cart.cart import Cart
  from django.shortcuts import render

  from .forms import OrderCreateForm
  from .models import OrderItem

  def order_create(request):
      cart = Cart(request)
      if request.method == 'POST':
          form = OrderCreateForm(request.POST)
          if form.is_valid():
              order = form.save()
              for item in cart:
                  OrderItem.objects.create(
                      order=order,
                      product=item['product'],
                      price=item['price'],
                      quantity=item['quantity']
                  )
              cart.clear()
              return render(
                  request, 'orders/order/created.html', {'order': order}
              )
      else:
          form = OrderCreateForm()
          return render(
              request, 'orders/order/create.html', {'cart': cart, 'form': form}
          )

  # myshop/orders/urls.py
  from django.urls import path
  from . import views

  app_name = "orders"
  urlpatterns = [
      path("create/", views.order_create, name="order_create"),
  ]

  # myshop/myshop/urls.py
      path("orders/", include("orders.urls", namespace="orders")),

  # myshop/cart/templates/cart/detail.html
  # find and replace
      <a href="#" class="button">Checkout</a>
  # with
      <a href="{% url "orders:order_create" %}" class="button">
        Checkout
      </a>

  # myshop/orders/templates/orders/order/create.html
  {% extends "shop/base.html" %}
  {% block title %}
    Checkout
  {% endblock %}
  {% block content %}
    <h1>Checkout</h1>
    <div class="order-info">
      <h3>Your order</h3>
      <ul>
        {% for item in cart %}
          <li>
            {{ item.quantity }}x {{ item.product.name }}
            <span>${{ item.total_price }}</span>
          </li>
        {% endfor %}
      </ul>
      <p>Total: ${{ cart.get_total_price }}</p>
    </div>
    <form method="post" class="order-form">
      {{ form.as_p }}
      <p><input type="submit" value="Place order"></p>
      {% csrf_token %}
    </form>
  {% endblock %}

  # myshop/orders/templates/orders/order/created.html
  {% extends "shop/base.html" %}
  {% block title %}
    Thank you
  {% endblock %}
  {% block content %}
    <h1>Thank you</h1>
    <p>Your order has been successfully completed. Your order number is
    <strong>{{ order.id }}</strong>.</p>
  {% endblock %}

  # myshop/shop/templates/shop/base.html
  # find and replace
            {% else %}
              Your cart is empty.
            {% endif %}
  # with
            {% elif not order %}
              Your cart is empty.
            {% endif %}
  ```

- Now we are going to asynchronously send an email when taking an order.
  Asynchronous execution can be used for any data-intensive, resource-intensive,
  or time-consuming process or any process subject to failure which might
  require a retry policy. To implement asynchronous tasks in this project, we
  will use Celery for managing task queues and RabbitMQ as the message broker.
- First we install celery: `pip install celery==5.4.0`. And we pull the RabbitMQ
  image via `docker pull rabbitmq:3.13.1-management1.` To run RabbitMQ,
  `docker run -it --rm --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3.13.1-management`.
  Then we can access RabbitMQ's management interface at `http://127.0.0.1:15672`
  in a browser. Use `guest` for both username and password.

  ```py
  # myshop/myshop/celery.py
  import os
  from celery import Celery

  os.environ.setdefault("DJANGO_SETTINGS_MODULE", "myshop.settings")
  app = Celery("myshop")
  app.config_from_object("django.conf:settings", namespace="CELERY")
  app.autodiscover_tasks()

  # myshop/myshop/__init__.py
  from .celery import app as celery_app

  __all__ = ["celery_app"]
  ```

- Now we can start a celery worker from another shell with:
  `celery -A myshop worker -l info --pool=threads`. 
  Now in your RabbitMQ Admin you should show
  some graphs, several connections, and several queues.
- The `CELERY_ALWAYS_EAGER` setting allows you to execute tasks locally in a
  synchronous manner instead of sending them to the queue. This is useful for
  running unit tests or executing the application without running Celery.
- Define tasks for Celery in a `tasks.py` file in your app directory:

  ```py
  # myshop/order/tasks.py
  from celery import shared_task
  from django.core.mail import send_mail
  from .models import Order

  @shared_task
  def order_created(order_id):
      """
      Task to send an e-mail notification when an order is
      successfully created.
      """
      order = Order.objects.get(id=order_id)
      subject = f"Order nr. {order.id}"
      message = (
          f"Dear {order.first_name},\n\n"
          f"You have successfully placed an order."
          f"Your order ID is {order.id}."
      )
      mail_sent = send_mail(subject, message, "admin@myshop.com", [order.email])
      return mail_sent

  # myshop/myshop/settings.py
  EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

  # myshop/orders/views.py
  from .tasks import order_created
  # ...
              cart.clear()
              order_created.delay(order.id)
              return render(request, "orders/order/created.html", {"order": order})
  ```

- It is recommended to only pass IDs to task functions and retrieve objects from
  the database when the task is executed.
- You call the `delay()` method of a task to execute is asynchronously.
- You can also monitor Celery with Flower. `pip install flower==2.0.1'` then
  from a new shell `celery -A myshop flower` and browsing to
  `http://localhost:5555/`. If this wasn't a development box, we'd run Flower
  with `celery -A myshop flower --basic-auth=user:pwd` where `user` and `pwd`
  are credentials to login. Flower also provides login via Google, GitHub, or
  Okta OAuth <https://flower.readthedocs.io/en/latest/auth.html>.

## Chapter 9 - Managing Payments and Orders

- We are going to integrate payments through
  [Stripe Checkout](https://stripe.com/docs/payments/checkout). First you need
  to [register](https://dashboard.stripe.com/register). Now you want to
  `pip install stripe==9.3.0`. And get your
  [api keys](https://dashboard.stripe.com/test/apikeys).

  ```py
  # myshop/.env
  STRIPE_PUBLISHABLE_KEY=pk_test_XXXX
  STRIPE_SECRET_KEY=sk_test_XXXX

  # myshop/myshop/settings.py
  from decouple import config

  STRIPE_PUBLISHABLE_KEY = config('STRIPE_PUBLISHABLE_KEY')
  STRIPE_SECRET_KEY = config('STRIPE_SECRET_KEY')
  STRIPE_API_VERSION = '2024-04-10'
  ```

- `./manage.py startapp payments` and add it to `INSTALLED_APPS`.

  ```py
  # myshop/orders/views.py
  from django.shortcuts import redirect, render
  # find these three lines and replace
              cart.clear()
              order_created.delay(order.id)
              return render(request, "orders/order/created.html", {"order": order})
  # with
              cart.clear()
              order_created.delay(order.id)
              request.session["order_id"] = order.id
              return redirect("payment:process")

  # myshop/payment/views.py
  from decimal import Decimal

  import stripe
  from django.conf import settings
  from django.shortcuts import get_object_or_404, redirect, render
  from django.urls import reverse

  from orders.models import Order

  stripe.api_key = settings.STRIPE_SECRET_KEY
  stripe.api_version = settings.STRIPE_API_VERSION

  def payment_process(request):
      order_id = request.session.get('order_id')
      order = get_object_or_404(Order, id=order_id)
      if request.method == 'POST':
          success_url = request.build_absolute_uri(
              reverse('payment:completed')
          )
          cancel_url = request.build_absolute_uri(
              reverse('payment:canceled')
          )
          # Stripe checkout session data
          session_data = {
              'mode': 'payment',
              'client_reference_id': order.id,
              'success_url': success_url,
              'cancel_url': cancel_url,
              'line_items': []
          }
          # add order items to the Stripe checkout session
          for item in order.items.all():
              session_data["line_items"].append(
                  {
                      "price_data": {
                          "unit_amount": int(item.price * Decimal("100")),
                          "currency": "usd",
                          "product_data": {
                              "name": item.product.name,
                          },
                      },
                      "quantity": item.quantity,
                  }
              )

          session = stripe.checkout.Session.create(**session_data)
          return redirect(session.url, code=303)
      else:
          return render(request, 'payment/process.html', locals())

  def payment_completed(request):
      return render(request, 'payment/completed.html')

  def payment_canceled(request):
      return render(request, 'payment/canceled.html')

  # myshop/payment/urls.py
  from django.urls import path
  from . import views

  app_name = "payment"

  urlpatterns = [
      path("process/", views.payment_process, name="process"),
      path("completed/", views.payment_completed, name="completed"),
      path("canceled/", views.payment_canceled, name="canceled"),
  ]

  # myshop/myshop/urls.py
      path("payment/", include("payment.urls", namespace="payment")),

  # myshop/payment/templates/payment/process.html
  {% extends "shop/base.html" %}
  {% load static %}
  {% block title %}Pay your order{% endblock %}
  {% block content %}
    <h1>Order summary</h1>
    <table class="cart">
      <thead>
        <tr>
          <th>Image</th>
          <th>Product</th>
          <th>Price</th>
          <th>Quantity</th>
          <th>Total</th>
        </tr>
      </thead>
      <tbody>
        {% for item in order.items.all %}
          <tr class="row{% cycle "1" "2" %}">
            <td>
              <img src="{% if item.product.image %}{{ item.product.image.url }}
              {% else %}{% static "img/no_image.png" %}{% endif %}"
            </td>
          <td>{{ item.product.name }}</td>
          <td class="num">${{ item.price }}</td>
          <td class="num">{{ item.quantity }}</td>
          <td class="num">${{ item.get_cost}}</td>
          </tr>
        {% endfor %}
        <tr class="total">
          <td colspan="4">Total</td>
          <td class="num">${{ order.get_total_cost }}</td>
        </tr>
      </tbody>
    </table>
    <form action="{% url "payment:process" %}" method="post">
      <input type="submit" value="Pay now">
      {% csrf_token %}
    </form>
  {% endblock %}

  # myshop/payment/templates/payment/completed.html
  {% extends "shop/base.html" %}
  {% block title %}Payment successful{% endblock %}
  {% block content %}
    <h1>Your payment was successful</h1>
    <p>Your payment has been processed successfully.</p>
  {% endblock %}

  # myshop/payment/templates/payment/canceled.html
  {% extends "shop/base.html" %}
  {% block title %}Payment canceled{% endblock %}
  {% block content %}
    <h1>Your payment has not been processed</h1>
    <p>There was a problem processing your payment.</p>
  {% endblock %}
  ```

- Stripe has card number for testing:
  - Successfuly payment: 4242 4242 4242 4242, CVC any three, Expiry any future
  - Failed payment: 4000 0000 0000 0002, CVC any three, Expiry any future date
  - Requires 3D: 4000 0025 0000 3155, CVC any three, Expiry any future
- You can see your successful payments at:
  <https://dashboard.stripe.com/test/payments>
- You can add a webhook to get notified of Stripe payments at:
  <https://dashboard.stripe.com/test/webhooks>. Click on "Test with a local
  listener".
- First run `brew install stripe-cli` then `stripe login` and run 
  `stripe listen --print-secret` to get the secret
  and store it as STRIPE_WEBHOOK_SECRET in your .env, then add
  `STRIPE_WEBHOOK_SECRET = config("STIPE_WEBHOOK_SECRET")` to 
  `myshop/settings.py`. Then we'll add our webhook:

  ```py
  # myshop/payment/webhooks.py
  import stripe
  from django.conf import settings
  from django.http import HttpResponse
  from django.views.decorators.csrf import csrf_exempt

  from orders.models import Order

  @csrf_exempt
  def stripe_webhook(request):
      payload = request.body
      sig_header = request.META["HTTP_STRIPE_SIGNATURE"]
      event = None
      try:
          event = stripe.Webhook.construct_event(
              payload, sig_header, settings.STRIPE_WEBHOOK_SECRET
          )
      except ValueError as e:
          # Invalid payload
          return HttpResponse(status=400)
      except stripe.SignatureVerificationError as e:
          # Invalid signature
          return HttpResponse(status=400)
      if event.type == 'checkout.session.completed':
          session = event.data.object
          if (session.mode == 'payment' and session.payment_status == 'paid'):
              try:
                  order = Order.objects.get(id=session.client_reference_id)
              except Order.DoesNotExist:
                  return HttpResponse(status=404)
              order.paid = True
              order.save()
      return HttpResponse(status=200)

  # myshop/payment/urls.py
  from . import views, webhooks

      path("webhook/", webhooks.stripe_webhook, name="stripe-webhook")
  ```

- At this point I had ten terminal windows open, so I did `pip install honcho`,
  and also `pip install watchfiles`, then wrote a `Procefile`, and ran 
  everything with `honcho start`. `celery` and `flower` use `watchfiles`.

  ```py
  # myshop/Procfile
  rabbitmq: docker run --rm --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3.13.1-management
  celery: watchfiles --filter python "celery -A myshop worker -l info --pool=threads" .
  flower: watchfiles --filter python "celery -A myshop flower" .
  web: python manage.py runserver
  stripe: stripe listen --all-snapshot --forward-to 127.0.0.1:8000/payment/webhook/
  ```

- So Stripe payments have a payment ID, and we want to associate that with our
  `Order` instead of simply marking it paid.

  ```py
  # myshop/orders/models.py
  from django.conf import settings

  class Order(models.Model):
      # ...
      stripe_id = models.CharField(max_length=250, blank=True)
      # ...
      def get_stripe_url(self):
          if not self.stripe_id:
              return ''
          if '_test_' in settings.STRIPE_SECRET_KEY:
              path = '/test/'
          else:
              path = '/'
          return f'https://dashboard.stripe.com{path}payments/{self.stripe_id}'

  # myshop/payment/webhooks.py
  def stripe_webhook(request):
      # ...
              order.paid = True
              order.stripe_id = session.payment_intent
              order.save()

  # myshop/orders/admin.py
  from django.utils.safestring import mark_safe

  def order_payment(obj):
      url = obj.get_stripe_url()
      if obj.stripe_id:
          html = f'<a href="{url}" target="_blank">{obj.stripe_id}</a>'
          return mark_safe(html)
      return ''

  order_payment.short_description = "Stripe payment"
  # ...
  class OrderAdmin(admin.ModelAdmin):
      # ...
      "paid",
      order_payment,
      "created",
      "updated"
  ]
  # ...
  ```

- Now, not only can we take orders but we can also process payment. Next we're
  going to work on exporting the orders as a CSV file with a custom action on
  the administration site. A custom action is just a regular function that
  receives the current `ModelAdmin` being displayed, the current request
  object as an `HttpRequest` instance, and a QuerySet for the objects selected
  by the user. It shows up in the Action: dropdown.

  ```py
  # myshop/orders/admin.py
  import csv
  import datetime

  from django.http import HttpResponse

  def export_to_csv(modeladmin, request, queryset):
      opts = modeladmin.model._meta
      content_disposition = (
          f'attachment; filename={opts.verbose_name}.csv'
      )
      response = HttpResponse(content_type='text/csv')
      response['Content-Disposition'] = content_disposition
      writer = csv.writer(response)
      fields = [
          field
          for field in opts.get_fields()
          if not field.many_to_many and not field.one_to_many
      ]
      # Write a first row with header information
      writer.writerow([field.verbose_name for field in fields])
      for obj in queryset:
          data_row = []
          for field in fields:
              value = getattr(obj, field.name)
              if isinstance(value, datetime.datetime):
                  value = value.strftime("%d/%m/%Y")
              data_row.append(value)
          writer.writerow(data_row)
      return response

  export_to_csv.short_description = "Export to CSV"
  ```
  class OrderAdmin(admin.ModelAdmin):
      # ...
      inlines = [OrderItemInline]
      actions = [export_to_csv]
  ```

- You can do more than adding actions by creating a custom administration
  template. You just have to make sure only staff users can access your view
  and that you maintain the administration look and feel by making your template
  extend an administration template.

  ```py
  # myshop/orders/views.py
  from django.contrib.admin.views.decorators import staff_member_required
  from django.shortcuts import get_object_or_404, redirect, render
  
  from .models import Order, OrderItem

  @staff_member_required
  def admin_order_detail(request, order_id):
      order = get_object_or_404(Order, id=order_id)
      return render(
          request, 'admin/orders/order/detail.html', {'order': order}
      )

  # myshop/orders/urls.py
      path(
          "admin/order/<int:order_id>/",
          views.admin_order_detail,
          name="admin_order_detail",
      ),

  # myshop/orders/templates/admin/orders/order/detail.html
  {% extends "admin/base_site.html" %}
  {% block title %}
    Order {{ order.id }} {{ block.super }}
  {% endblock %}
  {% block breadcrumbs %}
    <div class+"breadcrumbs">
      <a href="{% url "admin:index" %}">Home</a> &rsaquo;
      <a href="{% url "admin:orders_order_changelist" %}>Orders</a> &rsaquo;
      <a href="{% url "admin:orders_order_change" order.id %}">
        Order {{ order.id }}
      </a>
      &rsaquo; Detail
    </div>
  {% endblock %}
  {% block content %}
    <div class+"module">
      <h1>Order {{ order.id }}</h1>
      <ul class="object-tools">
        <li>
          <a href="#" onclick="window.print();">
            Print order
          </a>
        </li>
      </ul>
      <table>
        <tr>
          <th>Created</th>
          <td>{{ order.created }}</td>
        </tr>
        <tr>
          <th>Customer</th>
          <td>{{ order.first_name }} {{ order.last_name }}</td>
        </tr>
        <tr>
          <th>
            Email
          </th>
          <td><a href="mailto:{{ order.email }}">{{ order.email }}</a></td>
        </tr>
        <tr>
          <th>Address</th>
          <td>
            {{ order.address }},
            {{ order.postal_code }} {{ order.city }}
          </td>
        </tr>
        <tr>
          <th>Total amount</th>
          <td>${{ order.get_total_cost }}</td>
        </tr>
        <tr>
          <th>Status</th>
          <td>{% if order.paid %}Paid{% else %}Pending payment{% endif %}</td>
        </tr>
        <tr>
          <th>Stripe payment</th>
          <td>
            {% if order.stripe_id %}
              <a href="{{ order.get_stripe_url }}" target="_blank">
                {{ order.stripe_id }}
              </a>
            {% endif %}
          </td>
        </tr>
      </table>
    </div>
    <div class="module">
      <h2>Items bought</h2>
      <table style="width:100%">
        <thead>
          <tr>
            <th>Product</th>
            <th>Price</th>
            <th>Quantity</th>
            <th>Total</th>
          </tr>
        </thead>
        <tbody>
          {% for item in order.items.all %}
            <tr class="row{% cycle "1" "2" %}">
              <td>{{ item.product.name }}</td>
              <td class="num">${{ item.price }}</td>
              <td class="num">{{ item.quantity }}</td>
              <td class="num">${{ item.get_cost }}</td>
            </tr>
          {% endfor %}
          <tr class="total">
            <td colspan="3">Total</td>
            <td class="num">${{ order.get_total_cost }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  {% endblock %}

  # myshop/orders/admin.py
  from django.urls import reverse

  def order_detail(obj):
      url = reverse("orders:admin_order_detail", args=[obj.id])
      return mark_safe(f'<a href="{url}">View</a>')

  class OrderAdmin(admin.ModelAdmin):
      # ...
          "updated",
          order_detail,
      ]
  ```

- We're going to use WeasyPrint to change our HTML to PDF. The requirements are
  at <https://doc.courtboullion.org/weasyprint/stable/first_steps.html>, but
  for OS X it's as simple a `brew install weasyprint` then 
  `pip install WweasyPrint==61.2`. Then we make a special template:

  ```py
  # myshop/orders/templates/orders/order/pdf.html
  <html>
    <body>
      <h1>My Shop</h1>
      <p>
        Invoice no. {{ order.id }}<br />
        <span class="secondary">
          {{ order.created|date:"M d, Y" }}
        </span>
      </p>
      <h3>Bill to</h3>
      <p>
        {{ order.first_name }} {{ order.last_name }}<br />
        {{ order.email }}<br />
        {{ order.address }}<br />
        {{ order.postal_code }}, {{ order.city }}
      </p>
      <h3>Items bought</h3>
      <table>
        <thead>
          <tr>
            <th>Product</th>
            <th>Price</th>
            <th>Quantity</th>
            <th>Cost</th>
          </tr>
        </thead>
        <tbody>
          {% for item in order.items.all %}
            <tr class="row{% cycle "1" "2" %}">
              <td>{{ item.product.name }}</td>
              <td class="num">${{ item.price }}</td>
              <td class="num">{{ item.quantity }}</td>
              <td class="num">${{ item.get_cost }}</td>
            </tr>
          {% endfor %}
          <tr class="total">
            <td colspan="3">Total</td>
            <td class="num">${{ order.get_total_cost }}</td>
          </tr>
        </tbody>
      </table>
      <span class="{% if order.paid %}paid{% else %}pending{% endif %}">
        {% if order.paid %}Paid{% else %}Pending payment{% endif %}
      </span>
    </body>
  </html>

  # myshop/orders/views.py
  import weasyprint
  from django.contrib.admin.views.decorators import staff_member_required
  from django.contrib.staticfiles import finders
  from django.http import HttpResponse
  from django.shortcuts import get_object_or_404, redirect, render
  from django.template.loader import render_to_string

  from cart.cart import Cart

  from .forms import OrderCreateForm
  from .models import Order, OrderItem
  from .tasks import order_created

  @staff_member_required
  def admin_order_pdf(request, order_id):
      order = get_object_or_404(Order, id=order_id)
      html = render_to_string("orders/order/pdf.html", {"order": order})
      response = HttpResponse(content_type="application/pdf")
      response["Content-Disposition"] = f"filename=order_{order.id}.pdf"
      weasyprint.HTML(string=html).write_pdf(
          response, stylesheets=[weasyprint.CSS(finders.find("css/pdf.css"))]
      )
      return response

  # myshop/myshop/settings.py
  STATIC_ROOT = BASE_DIR / 'static'

  # then run
  $ python manage.py collectstatic

  # myshop/orders/urls.py
      path('admin/order/<int:order_id>/pdf/',
           views.admin_order_pdf,
           name='admin_order_pdf'
      ),

  # myshop/orders/admin.py
  def order_pdf(obj):
      url = reverse('orders:admin_order_pdf', args=[obj.id])
      return mark_safe(f'<a href="{url}">PDF</a>')

  order_pdf.short_description = 'Invoice'

  class OrderAdmin(admin.ModelAdmin):
      # ...
          "updated",
          order_detail,
          order_pdf,
      ]
  ```

- Now we have a pretty good looking PDF. We want to email it. Like usual with
  email we want to do it asynchronous:

  ```py
  # myshop/payment/tasks.py
  from io import BytesIO

  import weasyprint
  from celery import shared_task
  from django.contrib.staticfiles import finders
  from django.core.mail import EmailMessage
  from django.template.loader import render_to_string

  from orders.models import Order

  @shared_task
  def payment_completed(order_id):
      """
      Task to send an email notification when an order is successfully paid.
      """
      order = Order.objects.get(id=order_id)
      subject = f"My Shop - Invoice no. {order.id}"
      message = "Please, find attached the invoice for your recent purchase."
      email = EmailMessage(subject, message, "admin@myshop.com", [order.email])
      html = render_to_string("orders/order/pdf.html", {"order": order})
      out = BytesIO()
      stylesheets = [weasyprint.CSS(finders.find("css/pdf.css"))]
      weasyprint.HTML(string=html).write_pdf(out, stylesheets=stylesheets)
      email.attach(f"order_{order.id}.pdf", out.getvalue(), "application/pdf")
      email.send()

  # myshop/payment/webhooks.py
  from .tasks import payment_completed

  def stripe_webhook(request):
      # ...
              payment_completed.delay(order.id)
      return HttpResponse(status=200)
  ```

- We also added some lines to `myshop/settings.py` to cleanup the output:

  ```py
  # myshop/myshop/settings.py
  LOGGING = {
      "version": 1,
      "disable_existing_loggers": False,
      "loggers": {"fontTools": {"level": "ERROR"}},
  }

  EMAIL_BACKEND = "django.core.mail.backends.filebased.EmailBackend"
  EMAIL_FILE_PATH = BASE_DIR / "sent_emails"

  # myshop/orders/tasks.pyfrom celery.utils.log import get_task_logger
  logger = get_task_logger(__name__)
  # ...at the end of payment_completed:
  logger.info("Invoice emailed for order %s", order.id)
  ```

## Chapter 10 - Extending Your Shop

- First we're going to add coupons by running `manage.py startapp cocupons`.

  ```py
  # myshop/coupons/models.py
  from django.core.validators import MaxValueValidator, MinValueValidator
  from django.db import models

  class Coupon(models.Model):
      code = models.CharField(max_length=50, unique=True)
      valid_from = models.DateTimeField()
      valid_to = models.DateTimeField()
      discount = models.IntegerField(
          validators=[MinValueValidator(0), MaxValueValidator(100)],
          help_text="Percentage value (0 to 100)",
      )
      active = models.BooleanField()

      def __str__(self):
          return self.code

  # myshop/coupons/admin.py
  from django.contrib import admin

  from .models import Coupon

  @admin.register(Coupon)
  class CouponAdmin(admin.ModelAdmin):
      list_display = ["code", "valid_from", "valid_to", "discount", "active"]
      list_filter = ["active", "valid_from", "valid_to"]
      search_fields = ["code"]
  ```

- So now we need a way for customers to apply coupons to their purchase.
  1. The user add products to the shopping cart.
  2. The user can enter a coupon code in a form displayed on the shopping cart
     details page.
  3. When the user enters a coupon code and submits the form, you look for an
     existing coupon with the given code that is currently valid. You have to
     check that the coupon code matches the one entered by the user, that the
     `active` attribute is `True`, and that the current datetime is between the
     `valid_from` and `valid_to` values.
  4. If a coupon is found, you save it in the user's session and display the
     cart, including the discount applied to it and the updated total amount.
  5. When the user places an order, you save the coupon to the given order.

  ```py
  # myshop/coupons/forms.py
  from django import forms

  class CouponApplyForm(forms.Form):
      code = forms.CharField()

  # myshop/coupons/views.py
  from django.shortcuts import redirect
  from django.utils import timezone
  from django.views.decorators.http import require_POST

  from .forms import CouponApplyForm
  from .models import Coupon

  @require_POST
  def coupon_apply(request):
      now = timezone.now()
      form = CouponApplyForm(request.POST)
      if form.is_valid():
          code = form.cleaned_data["code"]
          try:
              coupon = Coupon.objects.get(
                  code__iexact=code, 
                  valid_from__lte=now, 
                  valid_to__gte=now, 
                  active=True
              )
              request.session["coupon_id"] = coupon.id
          except Coupon.DoesNotExist:
              request.session["coupon_id"] = None
      return redirect("cart:cart_detail")

  # myshop/coupons/urls.py
  from django.urls import path

  from . import views

  app_name = 'coupons'
  urlpatterns = [
      path('apply/', views.coupon_apply, name='apply')
  ]

  # myshop/myshop/urls.py
      path("coupons/", include("coupons.urls", namespace="coupons")),

  # myshop/cart/cart.py
  from coupon.models import Coupon

  class Cart:
      def __init__(self, request):
          # ...
        self.cart = cart
        self.coupon_id = self.session.get("coupon_id")
    # ...
    @property
    def coupon(self):
        if self.coupon_id:
            try:
                return Coupon.objects.get(id=self.coupon_id)
            except Ccoupon.DoesNotExist:
                pass
        return None

    def get_discount(self):
        if self.coupon:
            return (
                self.coupon.discount / Decimal(100)
            ) * self.get_total_price()
        return Decimal(0)

    def get_total_price_after_discount(self):
        return self.get_total_price() - self.get_discount()

  # myshop/cart/views.py
  from coupons.forms import CouponApplyForm

  def cart_detail(request):
      cart = Cart(request)
      for item in cart:
          item["update_quantity_form"] = CartAddProductForm(
              initial={"quantity": item["quantity"], "override": True}
          )
      coupon_apply_form = CouponApplyForm()
      return render(
          request, 
          "cart/detail.html", 
          {
              "cart": cart,
              "coupon_apply_form": coupon_apply_form
          }
      )

  # myshop/cart/templates/cart/detail.html
  # replace these five lines:
        <tr class="total">
          <td>Total</td>
          <td colspan="4"></td>
          <td class="num">${{ cart.get_total_price }}</td>
        </tr>
  # with:
        {% if cart.coupon %}
          <tr class="subtotal">
            <td>Subtotal</td>
            <td colspan="4"></td>
            <td class="num">${{ cart.get_total_price|floatformat:2 }}</td>
          </tr>
          <tr>
            <td>
              "{{ cart.coupon.code }}" coupon
              ({{ cart.coupon.discount }}% off)
            </td>
            <td colspan="4"></td>
            <td class="num neg">
              - ${{ cart.get_discount|floatformat:2 }}
            </td>
          </tr>
        {% endif %}
        <tr class="total">
          <td>Total</td>
          <td colspan="4"></td>
          <td class="num">
            ${{ cart.get_total_price_after_discount|floatformat:2 }}
          </td>
        </tr>
  ```
