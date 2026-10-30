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
