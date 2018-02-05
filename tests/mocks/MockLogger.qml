import QtQuick 2.0

QtObject {
    function log(thing) {
        console.log(thing)
    }

    function debug(thing) {
        console.debug(thing)
    }

    function info(thing) {
        console.info(thing)
    }

    function warn(thing) {
        console.warn(thing)
    }

    function error(thing) {
        console.error(thing)
    }
}
