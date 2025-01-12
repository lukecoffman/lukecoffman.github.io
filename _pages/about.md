---
permalink: /
title: "About"
author_profile: true
redirect_from: 
  - /about/
  - /about.html
---

My name is Luke Coffman. I'm a fourth-year undergraduate at the University of Colorado, Boulder, studying physics and mathematics while researching quantum information theory. In 2024, I was named a Goldwater Scholar and Astronaut Scholar. I currently work under Dr. Xun Gao at JILA, CU Boulder.

# Research Interests

I am interested in the theory of entanglement, how we can efficiently learn properties of quantum systems, and what quantum systems are useful for quantum computation.

# Publications

{% if site.author.googlescholar %}
  <div class="wordwrap">You can also find my articles on <a href="{{site.author.googlescholar}}">my Google Scholar profile</a>.</div>
{% endif %}

{% include base_path %}

{% if site.publication_category %}
  {% for category in site.publication_category  %}
    {% assign title_shown = false %}
    {% for post in site.publications reversed %}
      {% if post.category != category[0] %}
        {% continue %}
      {% endif %}
      {% unless title_shown %}
        ## {{ category[1].title }}
        {% assign title_shown = true %}
      {% endunless %}
      {% include archive-single.html %}
    {% endfor %}
  {% endfor %}
{% else %}
  {% for post in site.publications reversed %}
    {% include archive-single.html %}
  {% endfor %}
{% endif %}
