class EarthAPIError extends Error {
    var code : Number;

    function EarthAPIError(message : String, code : Number) {
        this.message = message;
        this.code = code;
    }
}