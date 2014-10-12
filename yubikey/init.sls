#!jinja|yaml

{% from 'yubikey/defaults.yaml' import rawmap_osfam with context %}
{% set datamap = salt['grains.filter_by'](rawmap_osfam, merge=salt['grains.filter_by'](rawmap_os|default({}), grain='os', merge=salt['pillar.get']('yubikey:lookup'))) %}

include: {{ datamap.sls_include|default([]) }}
extend: {{ datamap.sls_extend|default({}) }}

{% if 'yubico' in datamap.config.manage|default([]) %}
  {% set f = datamap.config.yubico|default({}) %}
yubico:
  file:
    - directory
    - name: {{ f.path|default('/etc/yubico') }}
    - mode: {{ f.mode|default(750) }}
    - user: {{ f.user|default('root') }}
    - group: {{ f.group|default('root') }}
{% endif %}

{% if 'global_authorized_yubikeys' in datamap.config.manage|default([]) %}
  {% set f = datamap.config.global_authorized_yubikeys|default({}) %}
global_authorized_yubikeys:
  file:
    - managed
    - name: {{ f.path|default('/etc/yubico/authorized_yubikeys') }}
    - source: {{ f.template_path|default('salt://yubikey/files/global_authorized_yubikeys') }}
    - mode: {{ f.mode|default(640) }}
    - user: {{ f.user|default('root') }}
    - group: {{ f.group|default('root') }}
    - template: jinja
    - context:
      user_keys: {{ datamap.user_keys|default({}) }}
{% endif %}
