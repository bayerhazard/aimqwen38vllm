{{- /* aimqwen38vllm.serving: resolve the chosen serving profile to its vetted
       CTX / SPEC / PREFIX_CACHE triple. `.Values.olaresEnv.SERVING_PROFILE`
       (editable in Settings) wins; `.Values.profile.serving` is the fallback.
       An unknown name fails the render with the valid list. */ -}}
{{- define "aimqwen38vllm.servingDict" -}}
{{- $profiles := dict
      "fast"  (dict "ctx" "fast"  "spec" "dflash2" "prefixCache" "1")
      "long"  (dict "ctx" "long"  "spec" "mtp"     "prefixCache" "1")
      "huge"  (dict "ctx" "huge"  "spec" "mtp"     "prefixCache" "1") -}}
{{- $wanted := .Values.olaresEnv.SERVING_PROFILE | default .Values.profile.serving -}}
{{- $serving := index $profiles $wanted -}}
{{- if not $serving -}}
{{- fail (printf "serving profile %q is not one of: fast, long, huge" $wanted) -}}
{{- end -}}
{{- $serving | toJson -}}
{{- end -}}

{{- /* aimqwen38vllm.supports: expand the market's short capability groups
       (`thinking,tools,vision`) into llm-init's supports_* keys. `vision`
       false drops the capability where the engine would refuse images. */ -}}
{{- define "aimqwen38vllm.supports" -}}
{{- $keys := list -}}
{{- range splitList "," .supports -}}
{{- $s := trim . -}}
{{- if eq $s "thinking" -}}
{{- $keys = concat $keys (list "supports_reasoning" "supports_reasoning_effort") -}}
{{- else if eq $s "tools" -}}
{{- $keys = concat $keys (list "supports_function_calling" "supports_parallel_function_calling" "supports_tool_choice") -}}
{{- else if eq $s "vision" -}}
{{- if $.vision -}}{{- $keys = append $keys "supports_vision" -}}{{- end -}}
{{- else if not (or (eq $s "none") (eq $s "")) -}}
{{- fail (printf "MODEL_SUPPORTS: %q is not one of thinking, tools, vision, none" $s) -}}
{{- end -}}
{{- end -}}
{{- join "," $keys -}}
{{- end -}}
