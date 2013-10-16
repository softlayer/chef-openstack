---
layout: page
title: Install Jekyll on Windows
slug: install-jekyll-windows
lead: "Got Windows? No problem. Take these instructions out for a spin."
baseurl: "../"
---

# Summary

Jekyll is a text transformation engine. The concept behind Jekyll is like this.

1. You write text using your preferred markup language (Markdown, Textile, HTML).
2. You serve your text up to Jekyll.
3. Jekyll churns your text through a single layout (or a series of layouts).

> These instructions are ideal for Windows 7 Professional. Adjustments may be necessary if you're using a different Windows OS or OS edition.

# Getting Started

Things to download before diving into these instructions.

- [Git for Windows](http://code.google.com/p/msysgit/downloads/detail?name=Git-1.8.4-preview20130916.exe&can=2&q=full+installer+official+git)
- Ruby 2.0.0 or greater ([x86](http://dl.bintray.com/oneclick/rubyinstaller/rubyinstaller-2.0.0-p247.exe?direct) or [x64](http://dl.bintray.com/oneclick/rubyinstaller/rubyinstaller-2.0.0-p247-x64.exe?direct))
- Development Kit for Ruby ([x86](http://rubyforge.org/frs/download.php/76805/DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe) or [x64](http://rubyforge.org/frs/download.php/76808/DevKit-mingw64-64-4.7.2-20130224-1432-sfx.exe))

## Install Git

The installer for Git is self-explanatory. It walks you through the entire install process. If you run into any issues, [check out Git's documentation and videos on their website](http://git-scm.com/doc).


## Install Ruby

1. Open Git and run these commands. This will create the install directories.
        
        $ mkdir c:\Ruby2.0.0
        $ mkdir c:\DevKit

2. Install Ruby into the C:\Ruby2.0.0 directory.
3. Install DevKit into the C:\DevKit directory.
4. Open Git and run these commands. The last command will put you back in your $HOME directory.

        $ cd c:\devkit
        $ ruby dk.rb init
        $ ruby dk.rb install
        $ cd $HOME

If you get any errors, go to C:\DevKit and open `config.yml`. Verify that your Ruby directory is listed correctly.

## Install Jekyll

Run the following commands in Git Bash. This will install Jekyll and create your first new website directory.

        $ gem install jekyll
        $ jekyll new your-website-name
        $ cd your-website-name
        $ jekyll serve

Verify that your website is "up" by opening a browser and going to [http://localhost:4000](http://localhost:4000).

### Jekyll Directory

A basic Jekyll site usually looks something like this.

        |-- _config.yml
        |-- _includes
            |-- footer.html
            |-- header.html
        |-- _layouts
            |-- default.html
            |-- post.html
        |-- _posts
        |-- _site
        |-- css
            |-- style.css
            |-- syntax.css
        |-- index.html


### Directory Overview

An overview of what most of these do is included below.

- The `_config.yml` stores configuration data.
- The `_includes` directory holds partials that can be mixed and matched by your layouts to facilitate reuse.
- The `_layouts` directory contains the templates that wrap posts.
- The `_site` directory is where the generated site is placed after Jekyll is done transforming it. Add this to your .gitignore file.
- Any file with a YAML Front Matter section will be transformed by Jekyll.
