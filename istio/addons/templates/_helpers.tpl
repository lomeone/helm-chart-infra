{{- define "prometheus.name" -}}
{{- default "istio-prometheus" .Values.prometheus.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "prometheus.labels" -}}
app.kubernetes.io/name: {{ include "prometheus.name" . }}
{{- end }}
