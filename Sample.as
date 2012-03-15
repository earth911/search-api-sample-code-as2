import EarthAPI;

class Sample {
    static var EARTH_API_URL:String = 'http://api.earth911.com/';
    static var EARTH_API_KEY:String = 'ENTER YOUR API KEY HERE';

    var earth911:EarthAPI;

    function Sample() {
        earth911 = new EarthAPI(EARTH_API_URL, EARTH_API_KEY);
    }

    function run(what:String, where:String,
                 onResult:Function, onError:Function):Void {
        var output:String = '';
        query(what, where, function(result:Object) {
            var locations:Array = result.locations;
            var locationDetails:Object = result.locationDetails;
            for (var i:Number = 0; i < locations.length; i++) {
                var location:Object = locations[i];
                var locationId:String = location.location_id;
                output += location.description;
                output += ' (' + location.distance + 'mi.)\n';
                if (typeof locationDetails[locationId] != 'undefined') {
                    var details:Object = locationDetails[locationId];
                    if (details.phone != '') {
                        output += details.phone + '\n';
                    }
                    output += details.address + '\n';
                    output += details.city + ', ';
                    output += details.province + ' ';
                    output += details.postal_code + '\n';
                    if (typeof details.materials != 'undefined'
                        && details.materials.length > 0) {
                        var materials:Array = [];
                        for (var j:Number = 0; j < details.materials.length; j++) {
                            materials.push(details.materials[j].description);
                        }
                        output += 'Materials accepted: ';
                        output += materials.join(', ');
                        output += '\n';
                    }
                    output += '\n';
                }
            }
            onResult(output);
        }, onError);
    }

    function query(what:String, where:String,
                   onResult:Function, onError:Function):Void {
        var self:Sample = this;
        var earth911:EarthAPI = this.earth911;
        var args:Object = {query: what};
        earth911.call('searchMaterials', args, function(materials:Array) {
            self.onMaterials(what, where, materials, onResult, onError);
        }, onError);
    }

    function onMaterials(what:String, where:String, materials:Array,
                         onResult:Function, onError:Function) {
        var self:Sample = this;
        var earth911:EarthAPI = this.earth911;
        var materialIds:Array = [];
        for (var i:Number = 0; i < materials.length; i++) {
            var material:Object = materials[i];
            materialIds.push(material.material_id);
            if (material.exact) break; // Exact match
        }
        var args:Object = {postal_code: where, country: 'US'};
        earth911.call('getPostalData', args, function(postal:Object) {
            var latitude:Number = postal.latitude;
            var longitude:Number = postal.longitude;
            self.doSearch(latitude, longitude, materialIds, onResult, onError);
        }, onError);
    }

    function doSearch(latitude:Number, longitude:Number, materialIds:Array,
                      onResult:Function, onError:Function) {
        var self:Sample = this;
        var earth911:EarthAPI = this.earth911;
        var args:Object = {
            latitude: latitude,
            longitude: longitude,
            material_id: materialIds,
            max_distance: 50,
            max_results: 20
        };
        earth911.call('searchLocations', args, function(locations:Array) {
            self.onSearch(locations, onResult, onError);
        }, onError);
    }

    function onSearch(locations:Array, onResult:Function, onError:Function) {
        var self:Sample = this;
        var earth911:EarthAPI = this.earth911;
        var locationIds:Array = [];
        for (var i:Number = 0; i < locations.length; i++) {
            locationIds.push(locations[i].location_id);
        }
        var args:Object = {location_id: locationIds};
        earth911.call('getLocationDetails', args, function(locationDetails:Array) {
            var result:Object = new Object();
            result.locations = locations;
            result.locationDetails = locationDetails;
            onResult(result);
        }, onError);
    }
}
