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

{% for post in site.publications reversed %}
  {% include front-page-pub.html %}
{% endfor %}
