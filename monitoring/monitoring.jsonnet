local k = import 'ksonnet/ksonnet.beta.3/k.libsonnet';
local secret = k.core.v1.secret;
local ingress = k.extensions.v1beta1.ingress;
local ingressTls = ingress.mixin.spec.tlsType;
local ingressRule = ingress.mixin.spec.rulesType;
local httpIngressPath = ingressRule.mixin.http.pathsType;

local kp =
  (import 'kube-prometheus/kube-prometheus.libsonnet') +
  {
    _config+:: {
      namespace: 'monitoring',
      grafana+:: {
        config+: {
          sections+: {
            server+: {
              root_url: 'http://grafana.cluster.lc',
            },
          },
        },
      },
    },
    alertmanager+:: {
      alertmanager+: {
        spec+: {
          externalUrl: 'http://alertmanager.cluster.lc',
        },
      },
    },
    prometheus+:: {
      prometheus+: {
        spec+: {
          externalUrl: 'http://prometheus.cluster.lc',
        },
      },
    },
    ingress+:: {
      'alertmanager-main':
        ingress.new() +
        ingress.mixin.metadata.withName('alertmanager-main') +
        ingress.mixin.metadata.withNamespace($._config.namespace) +
        ingress.mixin.metadata.withAnnotations({
          'nginx.ingress.kubernetes.io/auth-type': 'basic',
          'nginx.ingress.kubernetes.io/auth-secret': 'basic-auth',
          'nginx.ingress.kubernetes.io/auth-realm': 'Authentication Required',
        }) +
        ingress.mixin.spec.withRules(
          ingressRule.new() +
          ingressRule.withHost('alertmanager.cluster.lc') +
          ingressRule.mixin.http.withPaths(
            httpIngressPath.new() +
            httpIngressPath.mixin.backend.withServiceName('alertmanager-main') +
            httpIngressPath.mixin.backend.withServicePort('web')
          ),
        ),
      grafana:
        ingress.new() +
        ingress.mixin.metadata.withName('grafana') +
        ingress.mixin.metadata.withNamespace($._config.namespace) +
        ingress.mixin.spec.withRules(
          ingressRule.new() +
          ingressRule.withHost('grafana.cluster.lc') +
          ingressRule.mixin.http.withPaths(
            httpIngressPath.new() +
            httpIngressPath.mixin.backend.withServiceName('grafana') +
            httpIngressPath.mixin.backend.withServicePort('http')
          ),
        ),
      'prometheus-k8s':
        ingress.new() +
        ingress.mixin.metadata.withName('prometheus-k8s') +
        ingress.mixin.metadata.withNamespace($._config.namespace) +
        ingress.mixin.metadata.withAnnotations({
          'nginx.ingress.kubernetes.io/auth-type': 'basic',
          'nginx.ingress.kubernetes.io/auth-secret': 'basic-auth',
          'nginx.ingress.kubernetes.io/auth-realm': 'Authentication Required',
        }) +
        ingress.mixin.spec.withRules(
          ingressRule.new() +
          ingressRule.withHost('prometheus.cluster.lc') +
          ingressRule.mixin.http.withPaths(
            httpIngressPath.new() +
            httpIngressPath.mixin.backend.withServiceName('prometheus-k8s') +
            httpIngressPath.mixin.backend.withServicePort('web')
          ),
        ),
    },
  } + {
    ingress+:: {
      'basic-auth-secret':
        secret.new('basic-auth', { auth: std.base64(importstr 'auth') }) +
        secret.mixin.metadata.withNamespace($._config.namespace),
    },
  };

{ ['00namespace-' + name]: kp.kubePrometheus[name] for name in std.objectFields(kp.kubePrometheus) } +
{ ['0prometheus-operator-' + name]: kp.prometheusOperator[name] for name in std.objectFields(kp.prometheusOperator) } +
{ ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
{ ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
{ ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
{ ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
{ ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) } +
{ ['ingress-' + name]: kp.ingress[name] for name in std.objectFields(kp.ingress) }
