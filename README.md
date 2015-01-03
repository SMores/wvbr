README
======
This is the Rails App for 93.5 WVBR.

For beginners, for more information on how Rails works, including a thorough beginner's tutorial, check out [Mark Hartl's awesome book](https://www.railstutorial.org/book).

This app primarily utilizes [Refinery](http://refinerycms.com) for content management. Check out the [guides](http://refinerycms.com/guides) for some help getting started. Useful information will be documented here:

Adding page parts
-----------------
By default all pages are created with a Body and a Side Body. If additional parts are needed (for example, an ad): 
1. Go to the admin center and click on the pages tab
2. Click the edit icon for the page that you wish to edit
3. Click the small, green `+` under the title of the page
4. Type the name of the new part, click Save, then click the `x` to close the entry box
5. Make sure to click Save at the bottom of the page before leaving

Overwriting views
-----------------
If you find the need to overwrite a particular view, simply run `rake refinery:override view=refinery/pages/some_view` where `some_view` is the name of the view to be overwritten.

*note:* If the view that you wish to override is within a Refinery engine (say the Blog engine, for example), you'll find it within `refinery/blog/some_view`.
The full command for the form for a new blog post in the admin center, for example, would be `rake refinery:override view=refinery/blog/admin/posts/_form`. The full path for any file can be found at the respective engine's GitHub repo (for Blog, that would be [https://github.com/refinery/refinerycms-blog](https://github.com/refinery/refinerycms-blog)). These are all listed in the Gemfile.
