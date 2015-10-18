module.exports = {
    call: function(num, successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            "Linphone",
            "call",
            [num]
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
    toggleVideo: function(isOn, successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            "Linphone",
            "toggleVideo",
            [isOn]
        );
    }
};