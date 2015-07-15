
{% if salt['pillar.get']('splunkforwarder:deploymentclient:app_name', False) %}

deployment client app:
  file.managed:
    - name: /opt/splunkforwarder/etc/apps/{{ salt['pillar.get']('splunkforwarder:deploymentclient:app_name') }}/default/deploymentclient.conf
    - source: salt://splunkforwarder/etc-apps-deploymentclient/deploymentclient.conf
    - template: jinja
    - makedirs: True
    - require_in:
      - service: splunkforwarder
    - watch_in:
      - service: splunkforwarder



{% endif %}
