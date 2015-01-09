
libvirt_packages:
  pkg.installed:
    - pkgs:
      - qemu-kvm
      - libvirt-bin

libvirt_service:
  service.running:
    - name: libvirt-bin
    - enabled: true
    - restart: True

/etc/libvirt/secrets:
  file.directory:
    - user: root
    - group: root
    - mode: 0700

{% for secret in salt['pillar.get']('libvirt:secrets') %}
/etc/libvirt/secrets/{{ secret['uuid'] }}.xml:
  file.managed:
    - source: salt://libvirt/files/secret.xml
    - template: jinja
    - user: root
    - group: root
    - mode: 0600
    - defaults:
      uuid: {{ secret['uuid'] }}
    - require:
      - file: /etc/libvirt/secrets
    - watch_in:
      - service: libvirt_service
    
/etc/libvirt/secrets/{{ secret['uuid'] }}.base64:
  file.managed:
    - user: root
    - group: root
    - mode: 0600
    - contents: {{ secret['passphrase'] }} 
    - contents_newline: False
    - require:
      - file: /etc/libvirt/secrets
    - watch_in:
      - service: libvirt_service
{% endfor %}

