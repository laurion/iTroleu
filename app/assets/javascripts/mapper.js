var bucharestCoords = {
  lat: 44.4325,
  lng: 26.103889,
  zoom: 15
}

var geocoder;
var map;
var marker;

function setMarker(pos) {
  marker = new google.maps.Marker({
    position: pos,
    map: map,
    title: 'Click to zoom',
    draggable: true
  });

  google.maps.event.addListener(marker, 'dragend', setPositionInput);
}

function initializeMap(mapParams) {
  var mapOptions = {
    center: new google.maps.LatLng(bucharestCoords.lat, bucharestCoords.lng),
    zoom: bucharestCoords.zoom,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };
  
  map = new google.maps.Map($(mapParams.mapCanvas).get(0),
      mapOptions);
  map.jqParams = mapParams;
  geocoder = new google.maps.Geocoder();

  setMarker(map.getCenter());

  var session_coord = {
    lat: parseFloat($(mapParams.latInput).val()),
    lng: parseFloat($(mapParams.lngInput).val())
  }
  if (navigator.geolocation && !session_coord.lat && !session_coord.lng) {
    navigator.geolocation.getCurrentPosition(setCurrentPosition);
  } else if (session_coord.lat && session_coord.lng) {
    setCurrentPosition({
      coords: {
        latitude: session_coord.lat,
        longitude: session_coord.lng,
      }
    })
  }
}

function setCurrentPosition(pos) {
  var latlng = new google.maps.LatLng(pos.coords.latitude, pos.coords.longitude);
  marker.setPosition(latlng);
  map.setCenter(latlng);
  setPositionInput({latLng: latlng});
}

function showGeolocation(latLng) {
  geocoder.geocode({'latLng': latLng}, function(results, status) {
    var address = results[1].formatted_address;
    $(map.jqParams.point_input).val(address);
  });
}

function setPositionInput(pos) {
  $(map.jqParams.latInput).val(pos.latLng.Ya);
  $(map.jqParams.lngInput).val(pos.latLng.Za);
  showGeolocation(pos.latLng);
}

$(document).live('pageshow', function (event, ui) {
  var page = $('.ui-page-active');
  var page_url = $(page).find('div[data-role=content]').attr('pageurl');
  if (page_url == 'starting') {
    var jqparams = {
      point_input: $(page).find('.start_point_input'),
      latInput: $(page).find('.start_latitude'),
      lngInput: $(page).find('.start_longitude'),
      mapCanvas: $(page).find('.map_canvas')
    }
    initializeMap(jqparams);
  } else if (page_url == 'destination') {
    var jqparams = {
      point_input: $(page).find('.destination_point_input'),
      latInput: $(page).find('.destination_latitude'),
      lngInput: $(page).find('.destination_longitude'),
      mapCanvas: $(page).find('.map_canvas')
    } 
    initializeMap(jqparams);
  }
})

function showStationOnMap(station) {
  //console.log(station);
  var image = '/icons/bus.png';
  var lat = parseFloat(station["lat"]);
  var lng = parseFloat(station["lon"]);
  var myLatLng = new google.maps.LatLng(lat, lng);
  console.log(myLatLng);
  var beachMarker = new google.maps.Marker({
      position: myLatLng,
      map: map,
      icon: image
  });
}

function addStationsOnMap(res) {
  if (! map) {
    console.log("timeout");
    setTimeout(function() {
      addStationsOnMap(res), 100
    })
  } else {
    _.each(res, function (val) {
      setTimeout(function() {
        showStationOnMap(val), 2000
      })
    })
  }
}

$(document).ready(function() {
  $.get('/json/stations.json', function(res) {
    addStationsOnMap(res);
  })
});
