{{- define "spire-agent.conf" -}}
agent {
  allow_unauthenticated_verifiers = false
  data_dir = "/run/spire/data"
  insecure_bootstrap = false
  log_level = {{ .Values.config.log.level | quote }}
  log_format = {{ .Values.config.log.format | quote }}
  server_address = {{ .Values.config.server.address | quote }}
  server_port = {{ .Values.config.server.port | quote }}
  socket_path = "/run/spire/sockets/agent.sock"
  trust_bundle_path = "/run/spire/bootstrap/trust-bundle.crt"
  trust_domain = {{ (required "trustDomain is required" .Values.config.trustDomain) | quote }}
}

plugins {
  {{- if .Values.config.plugins.keyManager.memory.enabled }}
  KeyManager "memory" {
    plugin_data {
    }
  }
  {{- end }}

  {{- if .Values.config.plugins.nodeAttestor.k8sPsat.enabled }}
  NodeAttestor "k8s_psat" {
    plugin_data {
      cluster = {{ (required "nodeAttestor k8sPsat cluster is required" .Values.config.plugins.nodeAttestor.k8sPsat.cluster) | quote }}
      token_path = "/var/run/secrets/tokens/spire-agent"
    }
  }
  {{- end }}

  {{- if .Values.config.plugins.workloadAttestor.k8s.enabled }}
  WorkloadAttestor "k8s" {
    plugin_data {
      skip_kubelet_verification = {{ .Values.config.plugins.workloadAttestor.k8s.skipKubeletVerification }}
    }
  }
  {{- end }}

  {{- if .Values.config.plugins.workloadAttestor.unix.enabled }}
  WorkloadAttestor "unix" {
    plugin_data {
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