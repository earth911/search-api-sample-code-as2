import JSON;

class EarthAPI {
    var apiUrl:String;
    var apiKey:String;
    var json:JSON;

    function EarthAPI(apiUrl:String, apiKey:String) {
        this.apiUrl = apiUrl;
        this.apiKey = apiKey;
        this.json = new JSON();
    }

    function call(method:String, args:Object,
                  onResult:Function, onError:Function):Void {
        args.api_key = this.apiKey;
        var query:String = buildQuery(args);
        var url:String = this.apiUrl + 'earth911.' + method + '?' + query;
        var json:JSON = this.json;
        var req:XML = new XML();
        req.onData = function(data:String):Void {
            if (data) {
                var result:Object = json.parse(data);
                if (result.error) {
                    onError(new EarthAPIError(result.error, result.code));
                } else {
                    onResult(result.result);
                }
            } else {
                onError(new EarthAPIError('Error connecting to API server', -1));
            }
        };
        req.load(url);
    }

    private static function buildQuery(values:Object):String {
        var result:Array = [];
        for (var k:String in values) {
            addValues(result, [], k, values[k]);
        }
        for (var i:Number = 0; i < result.length; i++) {
            result[i] = escape(result[i][0]) + '=' + escape(result[i][1]);
        }
        return result.join('&');
    }

    private static function buildName(keys:Array):String {
        if (keys.length == 0) {
            return '';
        } else if (keys.length == 1) {
            return keys[0];
        } else {
            return keys[0] + '[' + keys.slice(1).join('][') + ']';
        }
    }

    private static function buildDate(date:Date):String {
        return (zeroFill(4, date.getUTCFullYear().toString()) + '-' +
                zeroFill(2, date.getUTCMonth().toString()) + '-' +
                zeroFill(2, date.getUTCDate().toString()) + 'T' +
                zeroFill(2, date.getUTCHours().toString()) + ':' +
                zeroFill(2, date.getUTCMinutes().toString()) + ':' +
                zeroFill(2, date.getUTCSeconds().toString()));
    }

    private static function zeroFill(n:Number, s:String):String {
        while (s.length < n) {
            s = '0' + s;
        }
        return s;
    }

    private static function addValues(result:Array, keys:Array,
                                      key:String, value:Object):Void {
        if (value == null) {
            return;
        } else if (value instanceof Array) {
            for (var i:Number = 0; i < value.length; i++) {
                addValues(result, keys.concat([key]), String(i), value[i]);
            }
        } else if (value instanceof Date) {
            result.push([buildName(keys.concat([key])),
                         buildDate(Date(Object(value)))]);
        } else if (typeof value == 'boolean' || value instanceof Boolean) {
            result.push([buildName(keys.concat([key])),
                         value == true ? '1' : '0']);
        } else if (typeof value == 'object'
                   && !(value instanceof String)
                   && !(value instanceof Number)) {
            for (var k:String in value) {
                addValues(result, keys.concat([key]), k, value[k]);
            }
        } else {
            result.push([buildName(keys.concat([key])), value]);
        }
    }
}
