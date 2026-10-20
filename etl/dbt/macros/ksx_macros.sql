{# 기본 속성 3종 #}
{% macro ksx_base(enterprise_id, plant_col) -%}
  '{{ enterprise_id }}' as "EnterpriseID",
  (select x.site_id  from {{ ref('xref_plant') }} x where x.src_plant = {{ plant_col }}) as "SiteID",
  (select x.plant_id from {{ ref('xref_plant') }} x where x.src_plant = {{ plant_col }}) as "PlantID"
{%- endmacro %}

{# 코드 변환: mapping/*/codes.csv를 seed로 적재해 사용 #}
{% macro ksx_code(system, group, col) -%}
  (select c.ksx_code from {{ ref('codes') }} c
    where c.src_system = '{{ system }}' and c.src_group = '{{ group }}' and c.src_code = {{ col }})
{%- endmacro %}

{# 수량 단위 환산 #}
{% macro ksx_qty(qty_col, unit_col, target_uom) -%}
  ({{ qty_col }} * (select u.factor from {{ ref('units') }} u where u.src_unit = {{ unit_col }} and u.ksx_uom = '{{ target_uom }}'))
{%- endmacro %}

{# 일시 정규화(KS X ISO 8601) #}
{% macro ksx_ts(col, tz) -%}
  ({{ col }} at time zone '{{ tz }}')
{%- endmacro %}
