{%- set p = inventory.parameters %} 
{%- set organizations = p.github.organization %}
#!/bin/sh
{% for org_name in organizations %}
  {%- set org = organizations[org_name] %} 
  {%- for repo in org["repos"] %}
    {%- if 'source' in repo %}

git clone --mirror {{ repo.source }} 
(
cd {{ repo.name }}.git &&\
git remote remove origin &&\
git remote add origin https://{{ p.github.account }}:{{ p.github.token }}@github.com/{{ org_name }}/{{ repo.name }} &&\
git push origin --all --force
) 

    {%- endif %}{# if source #}
  {%- endfor %}{# /for org["repos"] #}
{%- endfor %}
