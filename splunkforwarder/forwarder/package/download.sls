{%- set download_base_url = pillar['splunkforwarder']['download_base_url'] %}
{%- set package_filename = pillar['splunkforwarder']['package_filename'] %}
{%- set source_hash = pillar['splunkforwarder']['source_hash'] %}

{%- set temp_file_path = '/tmp'%}

include:
  - splunkforwarder.certs
  - splunkforwarder.user
  - splunkforwarder.forwarder.config


get-splunkforwarder-package:
  file:
    - managed
    - name: {{ temp_file_path }}/{{ package_filename }}
    - source: {{ download_base_url }}{{ package_filename }}
{% if source_hash %}
    - source_hash: {{ source_hash }}
{% endif %}

is-splunkforwarder-package-outdated:
  cmd.run:
    - cwd: {{ temp_file_path }}
    - stateful: True
    - names:
{% if grains['os'] == 'Ubuntu' %}
      - new=$(dpkg-deb --showformat='${Package} ${Version}\n' -W {{ package_filename }});
        old=$(dpkg-query --showformat='${Package} ${Version}\n' -W splunkforwarder);
        if test "$new" != "$old";
          then echo; echo "changed=true comment='new($new) vs old($old)'";
          else echo; echo "changed=false";
        fi;
{% elif grains['os'] == 'CentOS' %}
      - new=$(rpm -qpil {{ package_filename }} | grep Version | awk '{print $3}');
        old=$(rpm -qil splunkforwarder | grep Version | awk '{print $3}');
        if test "$new" != "$old";
          then echo; echo "changed=true comment='new($new) vs old($old)'";
          else echo; echo "changed=false";
        fi;
{% endif %}
    - require:
      - pkg: splunkforwarder

splunkforwarder:
  pkg.installed:
    - sources:
      - splunkforwarder: {{ temp_file_path }}/{{ package_filename }}
    - require:
      - user: splunk_user
      - file: get-splunkforwarder-package
  cmd.watch:
    - cwd: {{ temp_file_path }}
{% if grains['os'] == 'Ubuntu' %}
    - name: dpkg -i {{ package_filename }}
{% elif grains['os'] == 'CentOS' %}
    - name: rpm -Uhv {{ package_filename }}
{% endif %}
    - watch:
      - cmd: is-splunkforwarder-package-outdated
  file:
    - managed
    - name: /etc/init.d/splunkforwarder
    - source: salt://splunkforwarder/init.d/splunkforwarder.sh
    - template: jinja
    - mode: 500
  service:
    - running
    - name: splunkforwarder
    - enable: True
    - restart: True
    - require:
      - pkg: splunkforwarder
      - cmd: splunkforwarder
      - file: splunkforwarder
    - watch:
      - pkg: splunkforwarder
      - cmd: splunkforwarder
      - file: splunkforwarder
