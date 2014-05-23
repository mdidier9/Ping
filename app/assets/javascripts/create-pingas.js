var placeSearch, autocomplete, geocoder;

function initialize() {

  var mapOptions = {
    zoom: 17,
    center: new google.maps.LatLng(41.8899109, -87.6376566) // this needs to be the user's location, or the location of the last pinga in an incorrectly submitted form
  };

  var map = new google.maps.Map(document.getElementById('create-pinga-map'),
      mapOptions);

  var geocoder = new google.maps.Geocoder();

  var userMarker = new google.maps.Marker({
    position: map.getCenter(), // this should be the user's location
    map: map,
    title: 'Your current location',
    draggable: true
  });

  google.maps.event.addListener(userMarker, 'dragend', function() {
    var latLng = userMarker.getPosition();
    geocoder.geocode({'latLng': latLng}, function(results, status) {
      $('#autocomplete').val(results[0].formatted_address);
    });
  });

  autocomplete = new google.maps.places.Autocomplete(
    (document.getElementById('autocomplete')),
    { types: ['geocode'] }
  );

  google.maps.event.addListener(autocomplete, 'place_changed', function() {
    var place = autocomplete.getPlace();
    map.setCenter(place.geometry.location);
    map.setZoom(17);
    userMarker.setPosition(place.geometry.location);
    userMarker.setVisible(true);
  });

  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function(position) {
      var geolocation = new google.maps.LatLng(
          position.coords.latitude, position.coords.longitude);
      autocomplete.setBounds(new google.maps.LatLngBounds(geolocation,
          geolocation));
    });
  };

  google.maps.event.addListener(map, 'center_changed', function() {
    // 3 seconds after the center of the map has changed, pan back to the
    // marker.
    window.setTimeout(function() {
      map.panTo(userMarker.getPosition());
    }, 3000);
  });

  google.maps.event.addListener(userMarker, 'click', function() {
    map.setZoom(18);
    map.setCenter(userMarker.getPosition());
  });
}

google.maps.event.addDomListener(window, 'load', initialize);


// var mapLogic = function() {

//   // var map = new google.maps.Map(document.getElementById('create-pinga-map'));

//   // var marker = new google.maps.Marker({
//   //   map: map,
//   //   anchorPoint: new google.maps.Point(0, -29)
//   // });

//   autocomplete = new google.maps.places.Autocomplete(
//     (document.getElementById('autocomplete')),
//     { types: ['geocode'] }
//   );

//   google.maps.event.addListener(autocomplete, 'place_changed', function() {
//     marker.setVisible(false);
//     var place = autocomplete.getPlace();
//     map.setCenter(place.geometry.location);
//     map.setZoom(17);
//     marker.setPosition(place.geometry.location);
//     marker.setVisible(true);
//   });

//   if (navigator.geolocation) {
//     navigator.geolocation.getCurrentPosition(function(position) {
//       var geolocation = new google.maps.LatLng(
//           position.coords.latitude, position.coords.longitude);
//       autocomplete.setBounds(new google.maps.LatLngBounds(geolocation,
//           geolocation));
//     });
//   };

// }

// $(document).on("page:load", mapLogic);

// $(document).ready(mapLogic);