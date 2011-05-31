Tumble Out is a Tumblr to Jekyll migration utility. It extracts public and private posts from your tumblog and puts it in the "<your tumblog>/posts" folder, using the original format for the posts.

## Usage

    $ tumble_out [OPTIONAL] tumblog_url

If you only give it your tumblog url, Tumble Out will extract all public posts and assets. If you give it your credentials, private posts will appear in "<your tumblog>/private".

After it's all done, just copy your posts to your jekyll installation and have a joyful life static-site blogging.

    $ tumble_out -h

will show you all the available options.

## Source formats

Supported post formats are only HTML and Markdown. If you need Textile, feel free to fork it and send a pull request.