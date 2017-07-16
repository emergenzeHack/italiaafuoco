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

Le ultime 25 aree “bruciate”, in ordine di data decrescente, in Italia
Vedi <a href="https://medium.com/@aborruso/22f07afad899">qui</a> il post di Andrea Borruso.
<div class="row"><div class="col-md-12"> <div id="map"></div> </div> </div>


<script>
// initialize the map
var map = L.map('map')

// create the tile layer with correct attribution
var osmUrl='http://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png';
var osmAttrib='&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, Tiles courtesy of <a href="http://hot.openstreetmap.org/" target="_blank">Humanitarian OpenStreetMap Team</a>';
var osm = new L.TileLayer(osmUrl, {minZoom: 6, maxZoom: 19, attribution: osmAttrib});


var osm = new L.StamenTileLayer("toner-lite");
var sumLat = 0.;
var sumLon = 0.;

map.addLayer(osm).setView([42.629381, 13.288372], 6);

document.addEventListener("DOMContentLoaded", function(event) { 
$(function () {
    var urlFire="http://effis.jrc.ec.europa.eu/rest/2/burntareas/current/?limit=25&country=IT&ordering=-firedate&format=json"
    $.getJSON(
        urlFire,
        function (data) {
                spdata=data.results;
                for (var i=0; i<spdata.length; i++) {
                        p = spdata[i].shape.coordinates[0];
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
        });
});
});


</script>
