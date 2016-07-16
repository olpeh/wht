/*-
 * Copyright (c) 2014 Peter Tworek
 *
 * Copyright (C) 2015 Olavi Haapala.
 * <harbourwht@gmail.com>
 * Twitter: @0lpeh
 * IRC: olpe
 *
 * -Renamed everything to Logger
 * -Changed notification to banner.notify()
 * -Simplified
 * -Added sending as email
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the author nor the names of any co-contributors
 * may be used to endorse or promote products derived from this software
 * without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    allowedOrientations: Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted

    SilicaListView {
        anchors.fill: parent

        header: PageHeader {
            title: qsTr("Log viewer")
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Send to the developer")
                onClicked: {
                    banner.notify(qsTr("Launching email app"))
                    Log.send()
                }
            }
            MenuItem {
                //: Menu action allowing the user to save application log
                text: qsTr("Save log")
                onClicked: {
                    //: Remorse popup message telling the user log file will be saved
                    remorse.execute(qsTr("Saving the log"), function() {
                        Log.save()
                    })
                }
            }
        }

        RemorsePopup {
            id: remorse
        }

        model: Log

        Connections {
            target: Log
            onLogSaved: {
                Log.debug("Log saved to: " + path)
                banner.notify(qsTr("Log saved to") + ": " + path)
            }
        }

        delegate: Component {
            Rectangle {
                width: parent.width
                height: children[0].height + Theme.paddingMedium
                /*
                QString("[DEBUG] "),
                QString("[ERROR] "),
                QString("[WARN]  "),
                QString("[INFO]  ")
                */
                color: {
                    switch (type) {
                    case 0:
                        return "#662219B2"
                    case 1:
                        return "#66FF0000"
                    case 2:
                        return "#66FFFD00"
                    case 3:
                        return "#6641DB00"
                    default:
                        return "#000"
                    }
                }

                Label {
                    x: Theme.paddingMedium
                    width: parent.width - 2 * Theme.paddingMedium
                    anchors.centerIn: parent
                    font.pixelSize: Theme.fontSizeTiny
                    wrapMode: Text.Wrap
                    text: message
                }
            }
        }

        VerticalScrollDecorator {}
    }
    Banner {
        id: banner
    }
}
