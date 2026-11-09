{# 표준 원장 UK 유일성: 같은 UK 조합이 2행 이상이면 실패(구현안내서 6.6 UK 유일성) #}
{% test ksx_unique_key(model, columns) %}
select {% for c in columns %}"{{ c }}"{% if not loop.last %}, {% endif %}{% endfor %}, count(*) as n
from {{ model }}
group by {% for c in columns %}"{{ c }}"{% if not loop.last %}, {% endif %}{% endfor %}
having count(*) > 1
{% endtest %}

{# 코드 대응: 원천 코드값이 대응표(seed codes)의 그룹에 없으면 실패 — 발생 시 S2로 회귀 #}
{% test ksx_code_mapped(model, column_name, group) %}
select m.{{ column_name }} as src_code, count(*) as n
from {{ model }} m
where m.{{ column_name }} is not null
  and not exists (select 1 from {{ ref('codes') }} c
                  where c.src_group = '{{ group }}' and c.src_code = m.{{ column_name }}::text)
group by 1
{% endtest %}

{# 헤더·라인: 라인의 사업장·공장은 소속 헤더와 같은 값(정의서 작성기준). 다르면 실패 — 원천 정정 또는 S2 회귀.
   라인별로 다른 공장이 필요한 업무는 기본 속성이 아니라 확장 속성(예: 공급 공장)으로 정의한다(구현안내서 5.6) #}
{% test ksx_line_matches_header(model, headers, line_keys, header_keys) %}
with h as (
{% for hm in headers %}
    select {% for c in header_keys %}"{{ c }}", {% endfor %}"SiteID", "PlantID" from {{ ref(hm) }}
{% if not loop.last %}    union all{% endif %}
{% endfor %}
)
select {% for c in line_keys %}l."{{ c }}", {% endfor %}l."SiteID", l."PlantID", h."SiteID" as header_site, h."PlantID" as header_plant
from {{ model }} l
join h on {% for i in range(line_keys | length) %}l."{{ line_keys[i] }}"::text = h."{{ header_keys[i] }}"::text{% if not loop.last %} and {% endif %}{% endfor %}
where l."SiteID" is distinct from h."SiteID" or l."PlantID" is distinct from h."PlantID"
{% endtest %}
