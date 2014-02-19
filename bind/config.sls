{% from "bind/map.jinja" import map with context %}

include:
  - bind

bind_config:
  file:
    - managed
    - name: {{ map.config }}
    - source: {{ salt['pillar.get']('bind:config:tmpl', 'salt://bind/files/named.conf') }}
    - template: jinja
    - user: {{ salt['pillar.get']('bind:config:user', map.user ) }}
    - group: {{ salt['pillar.get']('bind:config:group', map.group) }}
    - mode: {{ salt['pillar.get']('bind:config:mode', '640') }}
    - require:
      - pkg: bind
    - watch_in:
      - service: bind

named_directory:
  file.directory:
    - name: {{ map.named_directory }}
    - user: {{ salt['pillar.get']('bind:config:user', map.user) }}
    - group: {{ salt['pillar.get']('bind:config:group', map.group) }}
    - mode: 775
    - makedirs: True
    - require:
      - pkg: bind

{% if grains['os_family'] == 'RedHat' %}
bind_local_config:
  file:
    - managed
    - name: {{ map.local_config }}
    - source: 'salt://bind/files/redhat/named.conf.local'
    - template: jinja
    - user: {{ salt['pillar.get']('bind:config:user', map.user) }}
    - group: {{ salt['pillar.get']('bind:config:group', map.group) }}
    - mode: {{ salt['pillar.get']('bind:config:mode', '644') }}
    - require:
      - pkg: bind
{% endif %}

{% if grains['os_family'] == 'Debian' %}
bind_local_config:
  file:
    - managed
    - name: {{ map.local_config }}
    - source: 'salt://bind/files/debian/named.conf.local'
    - template: jinja
    - user: {{ salt['pillar.get']('bind:config:user', map.user) }}
    - group: {{ salt['pillar.get']('bind:config:group', map.group) }}
    - mode: {{ salt['pillar.get']('bind:config:mode', '644') }}
    - require:
      - pkg: bind

bind_options_config:
  file:
    - managed
    - name: {{ map.options_config }}
    - source: 'salt://bind/files/debian/named.conf.options'
    - template: jinja
    - user: {{ salt['pillar.get']('bind:config:user', map.user) }}
    - group: {{ salt['pillar.get']('bind:config:group', map.group) }}
    - mode: {{ salt['pillar.get']('bind:config:mode', '644') }}
    - require:
      - pkg: bind

bind_default_zones:
  file:
    - managed
    - name: {{ map.default_zones_config }}
    - source: 'salt://bind/files/debian/named.conf.default-zones'
    - template: jinja
    - user: {{ salt['pillar.get']('bind:config:user', 'root') }}
    - group: {{ salt['pillar.get']('bind:config:group', 'bind') }}
    - mode: {{ salt['pillar.get']('bind:config:mode', '644') }}
    - require:
      - pkg: bind
{% endif %}

{% for key,args in salt['pillar.get']('bind:configured_zones', {}).iteritems()  -%}
{%- set file = salt['pillar.get']("available_zones:" + key + ":file") %}
{% if args['type'] == "master" -%}
zones-{{ file }}:
  file:
    - managed
    - name: {{ map.named_directory }}/{{ file }}
    - source: 'salt://bind/zones/{{ file }}'
    - user: {{ salt['pillar.get']('bind:config:user', map.user) }}
    - group: {{ salt['pillar.get']('bind:config:group', map.group) }}
    - mode: {{ salt['pillar.get']('bind:config:mode', '644') }}
    - watch_in:
      - service: bind
    - require:
      - file: {{ map.named_directory }}
{% endif %}
{% endfor %}
