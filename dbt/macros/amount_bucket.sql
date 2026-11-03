{% macro amount_bucket(column) %}
    case
        when {{ column }} < 100 then 'SMALL'
        when {{ column }} < 1000 then 'MEDIUM'
        else 'LARGE'
    end
{% endmacro %}

{% macro clickhouse__day_of_week(date, isoweek=true) %}
    {% if isoweek %}
        toDayOfWeek({{ date }})
    {% else %}
        modulo(toDayOfWeek({{ date }}), 7) + 1
    {% endif %}
{% endmacro %}
