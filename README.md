Tumble Out is a Tumblr to Jekyll migration utility. It extracts public and private posts from your tumblog and puts it in the "<your tumblog>/posts" folder, using Markdown for the posts.

## Usage

    $ tumble_out -f <tumblog url> [OPTIONAL]

If you only give it your tumblog url, Tumble Out will extract all public posts and assets. If you give it your credentials, private posts will appear in "<your tumblog>/private".

After it's all done, just copy posts and [layout][Layout] (if exported) to your jekyll installation and have a joyful life static-site blogging.

    $ tumble_out -h

will show you all the available options.

## Layout

Tumble Out can export your layout to give you a starting point, but you should take notice of copyright details and respect theme authors like the good internet citizen you are. If you wish to skip this step, use the *-L* flag in the command line.