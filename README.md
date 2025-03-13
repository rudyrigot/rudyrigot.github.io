# My Life in Weeks

If you are hoping for some magical sophisticated software, you are in for a disappointment.

That being said, if you were to want to fork this, it should work for you as-is. The main things to know:

- At the root are all the files meant to be served to the viewer's browser; under `src` are the stuff useful for generating the HTML.
- To set your own event dates, you want to modify `weeks.json`. It's pretty self-explanatory in there.
- Changing the intro is in the template `src/index.html`.
- The HTML generation is powered by `src/build.rb`. It is very short and dumb. Seriously, to regenerate, you do `ruby src/build.rb`.