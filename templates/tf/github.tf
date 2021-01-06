{% set p = inventory.parameters %} 
{% set organizations = p.github.organization %}
{% for org_name in organizations %}
{% set org = organizations[org_name] %} 
provider "github" {
  token =  "{{ p.github.token }}"  
  organization = "{{ org_name }}"
} 
  {% for repo in org["repos"] %}
resource "github_repository" "github_{{ org_name }}_{{ repo.name }}" {
  name        = "{{ repo.name }}"
  description = "{{ repo.description | default(repo.name) }}"
  visibility  = "{{ repo.visibility | default('public') }}"
  has_projects = {{ repo.projects | default("false", false) | string | lower}}
  has_issues = {{ repo.has_issues | default("true", true) | string | lower}}
  has_wiki = {{ repo.has_wiki | default("false", false) | string | lower}}
  lifecycle {
    prevent_destroy = {{ repo.prevent_destroy | default("true", true) | string | lower}}
  }
}
    {% if repo.secrets is defined %}
      {% for secret, plaintext_value in repo.secrets.items() %}
resource "github_actions_secret" "github_{{ org_name }}_{{ repo.name }}_{{ secret | lower }}" {
  repository       = "{{ repo.name }}"
  secret_name      = "{{ secret }}"
  plaintext_value  = "{{ plaintext_value }}" 
  depends_on = [
    github_repository.github_{{ org_name }}_{{ repo.name }},
  ]
}
      {% endfor %} {# for secret, plaintext_value in repo.secrets.items() #}
    {% endif %} {# if repo.secrets #}
  {% endfor %} {# for repo in org #}
{% endfor %} {# for organization in p.github.oganizaiton #} 
