---
layout: page
title: Incendi
permalink: /incendi/
---

<link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.0/dist/leaflet.css" />
<script src="https://unpkg.com/leaflet@1.0.0/dist/leaflet.js"></script>
<script src="http://maps.stamen.com/js/tile.stamen.js?v1.3.0"></script>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/Leaflet.awesome-markers/2.0.2/leaflet.awesome-markers.css" />
<script src="https://cdnjs.cloudflare.com/ajax/libs/Leaflet.awesome-markers/2.0.2/leaflet.awesome-markers.min.js"></script>
<style>
#map{ height: 400px }
</style>


<link rel="stylesheet" href="{{ site.url }}/css/Control.Geocoder.css" />
<script src="{{ site.url }}/js/Control.Geocoder.js"></script>

Le ultime 100 aree “bruciate”, in ordine di data decrescente, in Italia
Vedi <a href="https://medium.com/@aborruso/22f07afad899">qui</a> il post di Andrea Borruso.
<div class="row"><div class="col-md-12"> <div id="map"></div> </div> </div>


<div class="row">
<div class="col-md-6 col-md-offset-3">
<table class="table table-striped">
<thead><tr><th>Comune</th><th>Data</th><th>Area</th></tr></thead>
<tbody>
{% for incendio in site.data.EFFIS_IT.results %}
<tr><td>{{incendio.commune}}</td><td>{{incendio.firedate}}</td><td>{{incendio.area_ha}}</td></tr>
{% endfor %}
</tbody>
</table>
</div>
</div>

<script>


// initialize the map
var map = L.map('map')

var incendi=[];
{% for incendio in site.data.EFFIS_IT.results %}incendi.push({{incendio | jsonify}});{% endfor %}

// create the tile layer with correct attribution
var osmUrl='http://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png';
var osmAttrib='&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, Tiles courtesy of <a href="http://hot.openstreetmap.org/" target="_blank">Humanitarian OpenStreetMap Team</a>';
var osm = new L.TileLayer(osmUrl, {minZoom: 6, maxZoom: 19, attribution: osmAttrib});


var osm = new L.StamenTileLayer("toner-lite");
var sumLat = 0.;
var sumLon = 0.;

map.addLayer(osm).setView([42.629381, 13.288372], 6);

for (var i=0; i<incendi.length; i++) {
        p = incendi[i].shape.coordinates[0];
        var pp=[];
        for (var j = 0; j < p.length; j++) {
                var coords = p[j];
                pp.push([coords[1],coords[0]]);
        }
        var poly = L.polygon(pp, {
color: 'red',
fillColor: '#f03',
fillOpacity: 0.5
}).addTo(map);
}


</script>
