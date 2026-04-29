---
---
{% if site.env.DEFAULT_REVERSE_SORT == "1" %}
  {% assign images = site.static_files | photo_filter | visible_photos | reverse %}
{% else %}
  {% assign images = site.static_files | photo_filter | visible_photos %}
{% endif %}
(function(html) {
  const id = document.currentScript.getAttribute('data-photo-id');
  const url = document.currentScript.getAttribute('data-photo-url');
  const target = document.currentScript.getAttribute('data-target-id');
  const container = document.querySelector(`#${target}`);
  container.innerHTML = html;
  openPhoto("id-"+id, url);
  lazyload();
})(`{% include photos.html %}`);
