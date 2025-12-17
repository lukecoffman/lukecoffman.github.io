---
layout: archive
title: "CV"
permalink: /cv/
author_profile: true
redirect_from:
  - /resume
---

{% include base_path %}

## Highlights (**Full CV PDF**)
### Research and Education
- Ph.D. in Quantum Science and Engineering, Harvard, 2030 (expected)
- Interest Areas: Entanglement Theory, Quantum Learning Theory, and Representation Theory
- 1 peer-reviewed publication, 1 pre-print article
- 9 Graduate courses in Physics and Mathematics as of Spring 2025

### Awards and Fellowships
- NSF Graduate Research Fellow
- Los Alamos Quantum Computing Summer School (Summer 2025)
- Barry M. Goldwater Scholarship
- Astronaut Scholarship
- ORISE Internship at Oak Ridge National Laboratory
- USEQIP and Undergraduate Research Awardee at IQC

### Teaching and Outreach
- Collaboratively wrote and recieved $38k grant to bolster access to undergraduate research
- SPS co-president and math COSMOS vice-president (2024-2025)
- Mentoring and supervising three undergraduate research projects
- Undergraduate TA for PHYS 3090: Introduction to Quantum Computing at CU Boulder

## Publications
  <ul>{% for post in site.publications reversed %}
    {% include archive-single-cv.html %}
  {% endfor %}</ul>

## Talks
  <ul>{% for post in site.talks reversed %}
    {% include archive-single-talk-cv.html  %}
  {% endfor %}</ul>

## Teaching
  <ul>{% for post in site.teaching reversed %}
    {% include archive-single-cv.html %}
  {% endfor %}</ul>
