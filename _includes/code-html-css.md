# Code Guide

Standards for developing flexible, durable, and sustainable HTML and CSS.

# The Basics

1. All code in any code base should look like a single person typed it, no matter how many people contributed. 
2. Strive to maintain standards and semantics, but don't sacrifice pragmatism. Use the least amount of markup with the fewest intricacies whenever possible.

# HTML

Follow these standards when coding in HTML.

## Syntax

* Use soft-tabs with two spaces
* Nested elements should be indented once (2 spaces)
* Always use double quotes `"`, never single quotes `'`
* Don't include a trailing slash in self-closing elements

**Incorrect example**

	<!DOCTYPE html>
	<html>
	<head>
	<title>Page title</title>
	</head>
	<body>
	<img src='images/company-logo.png' alt='Company' />
	<h1 class='hello-world'>Hello, world!</h1>
	</body>
	</html>

**Correct example**

	<!DOCTYPE html>
	<html>
	  <head>
		<title>Page title</title>
	  </head>
	  <body>
		<img src="images/company-logo.png" alt="Company">
		<h1 class="hello-world">Hello, world!</h1>
	  </body>
	</html>

## HTML5 doctype

Enforce standards mode in every browser possible with this simple doctype at the beginning of every HTML page.

	<!DOCTYPE html>

## Attribute Order

HTML attributes should come in this particular order for easier reading of code.

* class
* id
* data
* for|type|href

Your markup should look like:

	<a class="" id="" data-modal="" href="">Example link</a>

# CSS

Follow these standards when coding in CSS.

## CSS Syntax

* Use soft-tabs with two spaces
* When grouping selectors, keep individual selectors to a single line
* Include one space before the opening brace of declaration blocks
* Place closing braces of declaration blocks on a new line
* Include one space after `:` in each property
* Each declaration should appear on its own line
* End all declarations with a semi-colon (`'`)
* Comma-separated values should include a space after each comma
* Don't include spaces after commas in RGB or RGBa colors, and don't preface values with a leading zero
* Lowercase all hex values, e.g., `#fff` instead of `#FFF`
* Use shorthand hex values where available, e.g., `#fff` instead of `#ffffff`
* Quote attribute values in selectors, e.g., `input[type="text"]`
* Avoid specifying units for zero values, e.g., `margin: 0;` instead of `margin: 0px;`
* [CleanCSS](http://cleancss.com) and [Dirty Markup](http://www.dirtymarkup.com) are good websites to help get you started

**Incorrect example**

	.selector, .selector-secondary, .selector[type=text] {
	  padding:15px;
	  margin:0px 0px 15px;
	  background-color:rgba(0, 0, 0, 0.5);
	  box-shadow:0 1px 2px #CCC,inset 0 1px 0 #FFFFFF
	}

**Correct example**

	.selector,
	.selector-secondary,
	.selector[type="text"] {
	  padding: 15px;
	  margin: 0 0 15px;
	  background-color: rgba(0,0,0,.5);
	  box-shadow: 0 1px 2px #ccc, inset 0 1px 0 #fff;
	}

Questions on the terms used here? See the [syntax section of the Cascading Style Sheets article](http://en.wikipedia.org/wiki/Cascading_Style_Sheets#Syntax) on Wikipedia.

## Declaration order

Group all related declarations together. This means placing positioning and box-model properties closest to the top, followed by typographic and visual properties.

	.declaration-order {
	  /* Positioning */
	  position: absolute;
	  top: 0;
	  right: 0;
	  bottom: 0;
	  left: 0;
	  z-index: 100;

	  /* Box-model */
	  display: block;
	  float: right;
	  width: 100px;
	  height: 100px;

	  /* Typography */
	  font: normal 13px "Helvetica Neue", sans-serif;
	  line-height: 1.5;
	  color: #333;
	  text-align: center;

	  /* Visual */
	  background-color: #f5f5f5;
	  border: 1px solid #e5e5e5;
	  border-radius: 3px;

	  /* Misc */
	  opacity: 1;
	}

For a complete list of properties and their order, check out [Recess](http://twitter.github.com/recess).

## Formatting Exceptions

In some cases, it makes sense to deviate slightly from the default [syntax](#css-syntax).

### Prefixed Properties

When using vendor prefixed properties, indent each property such that the value lines up vertically for easy multi-line editing.


	.selector {
	  -webkit-border-radius: 3px;
	     -moz-border-radius: 3px;
              border-radius: 3px;
	}

> Tip:
> In Textmate, use **Text > Edit Each Line in Selection**. 
> In Sublime Text 2, use **Selection > Add Previous Line**, and **Selection >  Add Next Line**.

### Rules with Single Declarations

In instances where several rules are present with only one declaration each, consider removing new line breaks for readability and faster editing.

	.span1 { width: 60px; }
	.span2 { width: 140px; }
	.span3 { width: 220px; }

	.sprite {
	  display: inline-block;
	  width: 16px;
	  height: 15px;
	  background-image: url(../img/sprite.png);
	}

	.icon           { background-position: 0 0; }
	.icon-home      { background-position: 0 -20px; }
	.icon-account   { background-position: 0 -40px; }

## Human-Readable

Code is written and maintained by people. Ensure your code is descriptive, well commented, and approachable by others.

### Comments

Great code comments convey context or purpose and should not just reiterate a component or class name.

**Incorrect example**

	/* Modal header */
	.modal-header {
	  ...
	}

**Correct example**

	/* Wrapping element for .modal-title and .modal-close */
	.modal-header {
	  ...
	}

### Class names

* Keep classes lowercase and use dashes (not underscores or camelCase)
* Avoid arbitrary shorthand notation
* Keep classes as short and succinct as possible
* Use meaningful names; use structural or purposeful names over presentational
* Prefix classes based on the closest parent component's base class

**Incorrect example**

	.t { ... }
	.red { ... }
	.header { ... }

**Correct example**

	.tweet { ... }
	.important { ... }
	.tweet-header { ... }

### Selectors

* Use classes over generic element tags
* Keep them short and limit the number of elements in each selector to three
* Scope classes to the closest parent when necessary (e.g., when not using prefixed classes)

**Incorrect example**

	span { ... }
	.page-container #stream .stream-item .tweet .tweet-header .username { ... }
	.avatar { ... }

**Correct example**

	.avatar { ... }
	.tweet-header .username { ... }
	.tweet .avatar { ... }

## Organization

* Organize sections of code by component
* Develop a consistent commenting hierarchy
* If using multiple CSS files, break them down by component

# Writing and Copy

Words are an important part of how software works. Just as we have a styleguide for our code, we have a styleguide for our tone and our voice. Even though there may be dozens of people creating a product, it should still sound like we speak in one consistent voice.

## Voice & Tone

Favor classy over cute. Act more like a human and less like a computer.

**Incorrect example**

    Successfully deleted the #{branch_name} branch.

**Correct example**

    Okay, the #{branch_name} branch has been deleted.

Consider these key behaviors when writing:

* Enthusiasm
* Confidence
* Helpfulness
* Patience
* Warmth
* Class 

Respect the reader, act like a human and use fewer words.

## Title Case

In title case, the first letters of all words—except those below—are capitalized.

Do not capitalize these words unless the sentence begins with it:

* Articles: **a, an, the**
* Conjunctions: **for, and, nor, but, or, yet, so**
* Prepositions: **through, in, to, as**

### Letter Case

Use the correct letter case for syntax, products, and branding, like SoftLayer, OpenStack, and Swift. Also, capitalize specific features, like Object Storage, Big Data, and Private Cloud.

### The Oxford Comma

Use the Oxford comma to improve readibility. This is the comma placed immediately before the conjunction (and, or, nor) in a series of three or more terms.

**Incorrect example**

    Portugal, Spain and France

**Correct example**

    Portugal, Spain, and France

## Terminology

We have a few words that are specific to GitHub that should be used in certain ways. Suggested approaches are in bold.

* **GitHub** vs. github or Github
* **SoftLayer** vs. Softlayer
* **repository** vs. repo
* **organization** vs. org
* **user** vs. customer 
* **username** vs. login

# Shared Objects

A number of our sites use similar objects/pages, like `footer.html`, `header.html`, and even layouts like `landing.html` and `pages.html`. Any change that's made should easily propagate to each of the sites without having to make any special changes. This way, we can drop files into any site and not worry about it showing the wrong information.

This is possible by housing all the particulars for the project in the `_config.yml` file. 

**Incorrect example**

	The release for Chef-OpenStack is now available at http://github.com/softlayer/chef-openstack.

**Correct example**

	[The release for {{ site.project }} is now available at {{ site.repo }}.]

The `_config.yml` file in the <i>correct example</i> would contain the following:

<output><pre><strong>project:</strong> Chef-OpenStack
<strong>repo:</strong> http://github.com/softlayer/chef-openstack
</pre></output>

# Giving Thanks

Inspired by [Idiomatic CSS](https://github.com/necolas/idiomatic-css) and the [GitHub Styleguide](http://github.com/styleguide).
