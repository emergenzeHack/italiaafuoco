---
layout: page
title: Press
permalink: /press/
---


<script src="//code.jquery.com/jquery-1.12.3.js"></script>
<script src="//cdn.datatables.net/1.10.12/js/jquery.dataTables.min.js"></script>
<script src="//cdn.datatables.net/plug-ins/1.10.12/sorting/date-eu.js"></script>

{: .table .table-striped #press}
Data            |Fonte                   |Titolo       |Link
:---------------|:-----------------------|:------------|:--------------
{% for member in site.data.press %} {{member.data | date: '%d/%m/%Y'}} | {{member.dove}} | {{member.titolo}} | [Fonte]({{member.link}})
{% endfor %}
