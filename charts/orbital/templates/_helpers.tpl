{{/*
Expand the name of the chart.
*/}}
{{- define "orbital.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "orbital.namespace" -}}
{{- default .Release.Namespace .Values.namespace -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "orbital.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "orbital.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "orbital.labels" -}}
helm.sh/chart: {{ include "orbital.chart" . }}
{{ include "orbital.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "streamServer.labels" -}}
helm.sh/chart: {{ include "orbital.chart" . }}
{{ include "streamServer.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "orbital.selectorLabels" -}}
app.kubernetes.io/name: {{ include "orbital.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "streamServer.selectorLabels" -}}
app.kubernetes.io/name: stream-server
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "orbital.metaLabels" -}}
app.kubernetes.io/name: {{ template "orbital.name" . }}
helm.sh/chart: {{ template "orbital.chart" . }}
app.kubernetes.io/instance: "{{ .Release.Name }}"
app.kubernetes.io/managed-by: "{{ .Release.Service }}"
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- range $key, $value := .Values.orbital.extraLabels }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end -}}

{{- define "streamServer.metaLabels" -}}
app.kubernetes.io/name: stream-server
helm.sh/chart: {{ template "orbital.chart" . }}
app.kubernetes.io/instance: "{{ .Release.Name }}"
app.kubernetes.io/managed-by: "{{ .Release.Service }}"
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- range $key, $value := .Values.streamServer.extraLabels }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end -}}

{{- define "orbital.getRepoTag" -}}
{{- if .unifiedRepoTag }}
{{- .unifiedRepoTag }}
{{- else if .repository }}
{{- .repository }}:{{ .tag }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "orbital.serviceAccountName" -}}
{{- if .Values.orbital.serviceAccount.create -}}
    {{ default (include "orbital.fullname" .) .Values.orbital.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.orbital.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the secret for service account token to use
*/}}
{{- define "orbital.serviceAccountTokenName" -}}
{{ include "orbital.serviceAccountName" . }}-token
{{- end -}}

{{- define "orbital.ingressVersion" -}}
{{- if (.Capabilities.APIVersions.Has "networking.k8s.io/v1/Ingress") -}}
networking.k8s.io/v1
{{- else if (.Capabilities.APIVersions.Has "networking.k8s.io/v1beta1/Ingress") -}}
networking.k8s.io/v1beta1
{{- else -}}
extensions/v1beta1
{{- end -}}
{{- end -}}

{{- define "orbital.autoscalingVersion" -}}
{{- if (.Capabilities.APIVersions.Has "autoscaling/v2") -}}
autoscaling/v2
{{- else if (.Capabilities.APIVersions.Has "autoscaling/v2beta2") -}}
autoscaling/v2beta2
{{- else -}}
autoscaling/v1
{{- end -}}
{{- end -}}

{{/*
Default environment variable configuration for orbital containers
*/}}
{{- define "orbital.defaultEnv" -}}
OPTIONS:
  value: >-
    --vyne.analytics.persistRemoteCallResponses={{ .Values.orbital.persistRemoteCallResponses }}
    --vyne.services.config-file=/opt/service/config/services/services.conf
    {{- if .Values.orbital.security.enabled }}
    --vyne.security.openIdp.enabled=true
    --vyne.security.openIdp.jwks-uri={{ .Values.orbital.security.jwksUri }}
    --vyne.security.openIdp.issuerUrl={{ .Values.orbital.security.issuerUrl }}
    --vyne.security.openIdp.clientId={{ .Values.orbital.security.clientId }}
    --vyne.security.openIdp.scope={{ .Values.orbital.security.scope }}
    --vyne.security.openIdp.require-https={{ .Values.orbital.security.requireHttps }}
    {{- end }}
    {{- if .Values.orbital.project.enabled }}
    --vyne.workspace.project-file={{ .Values.orbital.project.path }}
    {{- else }}
    --vyne.workspace.config-file={{ .Values.orbital.workspace.path }}
    {{- end }}
JAVA_OPTS:
  value: >-
    -XX:MaxRAMPercentage=75
    -XX:MinRAMPercentage=75
{{- end }}

{{- define "streamserver.defaultEnv" -}}
OPTIONS:
  value: >-
    --vyne.services.config-file=/opt/service/config/services/services.conf
JAVA_OPTS:
  value: >-
    -XX:MaxRAMPercentage=75
    -XX:MinRAMPercentage=75
{{- end }}
