include:
{% if salt['pillar.get']('splunkforwarder:intermediate', False) %}
  - splunkforwarder.intermediate-forwarder
{% endif %}
  - splunkforwarder.forwarder
  - splunkforwarder.certs
  - splunkforwarder.secret
  - splunkforwarder.user
{% if salt['pillar.get']('splunkforwarder:deploymentclient', False) %}
  - splunkforwarder.etc-apps-deploymentclient
{% endif %}