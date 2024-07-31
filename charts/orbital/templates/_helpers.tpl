{{/*
Expand the name of the chart.
*/}}
{{- define "orbital.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

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

{{/*
Selector labels
*/}}
{{- define "orbital.selectorLabels" -}}
app.kubernetes.io/name: {{ include "orbital.name" . }}
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
{{- if .Values.orbital.security.enabled }}
{{- if .Values.orbital.security.jwksUri }}
VYNE_SECURITY_OPENIDP_JWKSURI:
  value: {{ .Values.orbital.security.jwksUri }}
{{- end }}
{{- if .Values.orbital.security.issuerUrl }}
VYNE_SECURITY_OPENIDP_ISSUERURL:
  value: {{ .Values.orbital.security.issuerUrl }}
{{- end }}
{{- if .Values.orbital.security.clientId }}
VYNE_SECURITY_OPENIDP_CLIENTID:
  value: {{ .Values.orbital.security.clientId }}
{{- end }}
VYNE_SECURITY_OPENIDP_SCOPE:
  value: {{ .Values.orbital.security.scope }}
{{- if .Values.orbital.security.accountManagementUrl }}
VYNE_SECURITY_OPENIDP_ACCOUNTMANAGEMENTURL:
  value: {{ .Values.orbital.security.accountManagementUrl }}
{{- end }}
{{- if .Values.orbital.security.orgManagementUrl }}
VYNE_SECURITY_OPENIDP_ORGMANAGEMENTURL:
  value: {{ .Values.orbital.security.orgManagementUrl }}
{{- end }}
{{- if .Values.orbital.security.identityTokenKind }}
VYNE_SECURITY_OPENIDP_IDENTITYTOKENKIND:
  value: {{ .Values.orbital.security.identityTokenKind }}
{{- end }}
{{- if .Values.orbital.security.oidcDiscoveryUrl }}
VYNE_SECURITY_OPENIDP_OIDCDISCOVERYURL:
  value: {{ .Values.orbital.security.oidcDiscoveryUrl }}
{{- end }}
{{- if .Values.orbital.security.rolesFormat }}
VYNE_SECURITY_OPENIDP_ROLES_FORMAT:
  value: {{ .Values.orbital.security.rolesFormat }}
{{- end }}
{{- if .Values.orbital.security.rolesPath }}
VYNE_SECURITY_OPENIDP_ROLES_PATH:
  value: {{ .Values.orbital.security.rolesPath }}
{{- end }}
{{- end }}
OPTIONS:
  value: >-
    --vyne.analytics.persistRemoteCallResponses={{ .Values.orbital.persistRemoteCallResponses }}
    --vyne.services.config-file=/opt/service/config/services/services.conf
    --vyne.stream-server.enabled={{ .Values.orbital.streamServer.enabled }}
    {{- if .Values.orbital.security.enabled }}
    --vyne.security.openIdp.enabled=true
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
