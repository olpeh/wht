import QtQuick 2.0
import QtTest 1.0

TestCase {
    property int defaultClickWaitMillis: 2000

    function findElementWithId(root, id) {
        return findElementWithProperty(root, "id", id, true, true);
    }

    function findElementWithObjectName(root, name) {
        return findElementWithProperty(root, "objectName", name, true, true);
    }

    function clickElement(element) {
        mouseClick(element, element.width / 2, element.height / 2);
        wait(defaultClickWaitMillis);
    }

    function openPullDownMenu(element) {
        var x = element.width / 2;
        var startY = element.height / 10;
        mousePress(element, x, startY);
        for (var i = 1; i <= 5; i++) {
            mouseMove(element, x, startY * i);
        }
        mouseRelease(element, x, startY * i);
    }

    function clickPullDownElement(parent, name) {
        openPullDownMenu(parent);
        clickElement(findElementWithObjectName(parent, name));
    }

    function findElementWithProperty(parent, propertyKey, propertyValue, exact, root) {
        if (exact && parent[propertyKey] === propertyValue) {
            return parent
        }

        if (!exact && parent[propertyKey] !== undefined && parent[propertyKey].search(propertyValue) !== -1) {
            return parent
        }

        if (parent.children !== undefined) {
            for (var i = 0; i < parent.children.length; i++) {
                var element = findElementWithProperty(parent.children[i], propertyKey,
                                                      propertyValue, exact, false);
                if (element !== undefined) return element;
            }
        }

        if (root) {
            fail("Element with property key '" + propertyKey + "' and value '" +
                 propertyValue + "' not found");
        } else {
            return undefined;
        }
    }
}
