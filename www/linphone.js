module.exports = {
    login: function(username, password, domain, successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            "Linphone",
            "login",
            [username, password, domain]
        );
    },
    logout: function(successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            "Linphone",
            "logout",
            []
        );
    },
    call: function(address, displayName, successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            "Linphone",
            "call",
            [address, displayName]
        );
    },
    hangup: function(successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            "Linphone",
            "hangup",
            []
        );
    },
    toggleVideo: function(successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            "Linphone",
            "toggleVideo",
            []
        );
    }
};