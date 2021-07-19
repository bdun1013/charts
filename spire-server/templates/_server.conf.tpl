{{- define "spire-server.conf" -}}
server {
  bind_address = {{ .Values.config.bind.address | quote }}
  bind_port = {{ .Values.config.bind.port | quote }}
  ca_key_type = {{ .Values.config.ca.keyType | quote }}
  ca_subject = {
    country = [{{ (required "ca subject country is required" .Values.config.ca.subject.country) | quote }}],
    organization = [{{ (required "ca subject organization is required" .Values.config.ca.subject.organization) | quote }}],
    common_name = {{ (required "ca subject commonName is required" .Values.config.ca.subject.commonName) | quote }},
  }
  ca_ttl = {{ .Values.config.ca.ttl | quote }}
  data_dir = "/run/spire/data"
  default_svid_ttl = "1h"
  log_level = {{ .Values.config.log.level | quote }}
  log_format = {{ .Values.config.log.format | quote }}
  socket_path = "/run/spire/sockets/api.sock"
  trust_domain = {{ (required "trustDomain is required" .Values.config.trustDomain) | quote }}
}

plugins {
  {{- if .Values.config.plugins.dataStore.sql.enabled }}
  DataStore "sql" {
    plugin_data {
      database_type = {{ .Values.config.plugins.dataStore.sql.databaseType | quote }}
      connection_string = {{ .Values.config.plugins.dataStore.sql.connectionString | quote }}
    }
  }
  {{- end }}

  {{- if .Values.config.plugins.keyManager.disk.enabled }}
  KeyManager "disk" {
    plugin_data {
      keys_path = "/run/spire/data/keys.json"
    }
  }
  {{- end }}

  {{- if .Values.config.plugins.nodeAttestor.k8sPsat.enabled }}
  NodeAttestor "k8s_psat" {
    plugin_data {
      clusters = {
        {{ (required "nodeAttestor k8sPsat cluster is required" .Values.config.plugins.nodeAttestor.k8sPsat.cluster) | quote }} = {
          service_account_allow_list = [{{ .Values.config.plugins.nodeAttestor.k8sPsat.serviceAccountAllowList | quote }}]
        }
      }
    }
  }
  {{- end }}

  {{- if .Values.config.plugins.upstreamAuthority.disk.enabled }}
  UpstreamAuthority "disk" {
    plugin_data {
      key_file_path = "/run/spire/bootstrap/tls.key"
      cert_file_path = "/run/spire/bootstrap/tls.crt"
    }
  }
  {{- end }}

  {{- if .Values.config.plugins.notifier.k8sbundle.enabled }}
  Notifier "k8sbundle" {
    plugin_data {
      config_map = "trust-bundle"
      config_map_key = "trust-bundle.crt"
    }
  }
  {{- end }}
}

health_checks {
  listener_enabled = {{ .Values.config.healthChecks.enabled }}
  bind_address = {{ .Values.config.healthChecks.bind.address | quote }}
  bind_port = {{ .Values.config.healthChecks.bind.port | quote }}
  live_path = {{ .Values.config.healthChecks.livePath | quote }}
  ready_path = {{ .Values.config.healthChecks.readyPath | quote }}
}
{{- end }}