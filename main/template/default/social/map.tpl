{% extends 'layout/layout_1_col.tpl'|get_template %}

{% block content %}
    <div id="map" style="width:100%; height:600px"></div>
<script>
function start()
{
    var options = {
        center: new google.maps.LatLng(54.526, 15.255), // "Europe center"
        zoom: 4,
        mapTypeId: google.maps.MapTypeId.ROADMAP
    };

    var map = new google.maps.Map(document.getElementById("map"), options);
    var oms = new OverlappingMarkerSpiderfier(map);
    var cities = '{{ places }}';
    cities = JSON.parse(cities);

    var imageCity = {
        url: '{{ image_city }}'
    }

    var stageCity = {
        url:'{{ image_stage }}'
    }

    // Add markers
    var markers = [];
    if (cities.length) {
        for (var i = 0; i < cities.length; i++) {
            // Add ville
            if ('ville_lat' in cities[i]) {
                var markerOptions = {
                    position: new google.maps.LatLng(cities[i]['ville_lat'], cities[i]['ville_long']),
                    title: cities[i]['complete_name'],
                    city: cities[i],
                    icon: imageCity,
                };
                var marker = new google.maps.Marker(markerOptions);
                markers.push(marker);
                oms.addMarker(marker);
            }

            // Add stage
            if ('stage_lat' in cities[i]) {
                var markerOptions = {
                    position: new google.maps.LatLng(cities[i]['stage_lat'], cities[i]['stage_long']),
                    title: cities[i]['complete_name'],
                    city: cities[i],
                    icon: stageCity,
                };
                var marker = new google.maps.Marker(markerOptions);
                markers.push(marker);
                oms.addMarker(marker);
            }
        }

        // Enable cluster
        var markerClusterer = new MarkerClusterer(map, markers, {
            maxZoom: 9, // maxZoom set when clustering will stop
            imagePath: 'https://cdn.rawgit.com/googlemaps/js-marker-clusterer/gh-pages/images/m'
        });

        // Auto-boxing
        var bounds = new google.maps.LatLngBounds();
        for (var i = 0; i < markers.length; ++i) {
            bounds.extend(markers[i].position);
        }
        map.fitBounds(bounds);

        // window when clicking
        var infoWindow = new google.maps.InfoWindow();
        oms.addListener('click', function (marker, event) {
            infoWindow.setContent('<a href="{{ url }}?u=' + marker.city['id'] + '">' + marker.city['complete_name'] + '</a>');
            infoWindow.open(map, marker);
        });

        google.maps.event.addListener(markerClusterer, 'clusterclick', function (cluster) {
            map.fitBounds(cluster.getBounds());
            if (map.getZoom() > 14) {
                map.setZoom(14);
            }
        });
    }
}
</script>
<script async defer type="text/javascript" src="https://maps.google.com/maps/api/js?key={{ api_key }}&callback=start"></script>

{% endblock %}