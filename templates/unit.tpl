# -*- mode: conf -*-

[Unit]
{% block unit -%}
Description={{summary}}
Documentation={{URL}}
After=network.target
{%- endblock unit %}

[Service]
{% block service -%}
EnvironmentFile=-/etc/default/{{name}}
User={{user}}
ExecStart=/usr/bin/{{name}} ${{name|upper}}_OPTS
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=5s
{% if open_file_limit is defined -%}
LimitNOFILE={{open_file_limit}}
{% endif %}
{% if memory_max is defined -%}
MemoryMax={{memory_max}}
{% endif %}
{% if memory_high is defined -%}
MemoryHigh={{memory_high}}
{% endif %}
{%- endblock service %}

[Install]
{% block install -%}
WantedBy=multi-user.target
{% endblock install %}
