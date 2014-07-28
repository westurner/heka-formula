{% from "heka/map.jinja" import heka with context %}

heka:
  pkg.installed:
    - sources:
      {% if grains['osarch'] == 'amd64' %}
      - heka: {{ heka.pkgsrc_amd64 }}
      {% elif grains['osarch'] == 'i386' %}
      - heka: {{ heka.pkgsrc_i386 }}
      {% endif %}

/etc/heka/hekad.toml:
  file.managed:
    - name: {{ heka.config }}
    - makedirs: True
    - template: {{ heka.config_src_template }}
    - source: {{ heka.config_src }}
    - user: root
    - group: root
    - mode: 0644

/etc/init/hekad.conf:
  file.managed:
    - source: 'salt://heka/files/hekad.conf'
    - user: root
    - group: root
    - mode: 0644

hekad:
  service:
    - running
    - enable: True
    - watch:
      - pkg: heka
      - file: /etc/init/hekad.conf
      - file: /etc/heka/hekad.toml
    - require:
      - file: /etc/init/hekad.conf
      - file: /etc/heka/hekad.toml

