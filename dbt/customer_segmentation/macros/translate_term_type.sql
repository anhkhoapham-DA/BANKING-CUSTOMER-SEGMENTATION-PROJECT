{% macro translate_term_type(term_type_column) -%}
CASE {{ term_type_column }}
    WHEN N'Ngắn hạn' THEN N'Short-term'
    WHEN N'Trung hạn' THEN N'Medium-term'
    WHEN N'Dài hạn' THEN N'Long-term'
    ELSE {{ term_type_column }}
END
{%- endmacro %}
