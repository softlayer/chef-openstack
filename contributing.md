---
layout: pages
title: Become a Contributor
slug: contributing
baseurl: "../"
---

# Become a Contributor

Looking to be a contributor? Here's how you can help.

# Guidelines

Read our contributing guidelines below. They include how to handle feature requests and issues, directions for pull requests, and our coding standards.

## Feature Requests

We are not actively accepting community requests. We are, however, accepting any reproducible issues found within the {{ site.project }} core.

## Issues

Have an issue to report? Here are some guidelines to read through first.

### Check the list of closed issues

Scroll through our list of [closed issues]({{ site.closed_issues }}) to see if yours has already been resolved or reported.

### Provide as much information as possible

Be sure to include any relevant information, such as the OpenStack release (Grizzly, Havana), which version, what components you use, when it was deployed, and so on.

### Use Gist to help explain the issue

Create a [gist](https://gist.github.com) of the code causing the issue, as well as any error messages, and include its URL in the issue report.

### Open a new issue

Create a [new issue on GitHub]({{ site.open_issues }}).

## Pull Requests

Below is our workflow for pull requests.

1.  Visit our [GitHub repo]({{ site.repo }}).
2.  Pick something you'd like to hack on, including any items loitering in the [issues lists]({{ site.open_issues }}).
3.  Fork the project and work in a topic branch.
4.  Make sure any changes you made work with {{ site.project }}.
5.  Add any documents or instructions that describe the behavior you're committing.
6.  [Rebase](https://help.github.com/articles/interactive-rebase) your branch against the `master` to ensure everything is up to date.
7.  Commit your changes and send a pull request.

{% include code-ruby.md %}

{% include docs.md %}

## Contribute to Our Docs

Our docs are treated like our code. 

* We publish our Getting Started guide on [GitHub Pages](http://pages.github.com) and use GitHub to track and manage changes.
* Our web resources for [Chef-OpenStack](http://softlayer.guthub.io/chef-openstack) are managed under the `gh-pages` [branch](https://github.com/softlayer/chef-openstack/tree/gh-pages).
* The [wiki on GitHub](https://github.com/softlayer/chef-openstack/wiki/_pages) is a clone of our online content. We use it for sharing while we’re working remote. 

{% include community.md %}

{% include copyright.md %}
