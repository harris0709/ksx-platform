{# 설정한 스키마 이름을 그대로 쓴다(기본 동작은 '<target 스키마>_<설정>'으로 붙인다) #}
{% macro generate_schema_name(custom_schema_name, node) -%}
  {%- if custom_schema_name is none -%}{{ target.schema }}{%- else -%}{{ custom_schema_name | trim }}{%- endif -%}
{%- endmacro %}
