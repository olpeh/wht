/*
Copyright (C) 2015 Olavi Haapala.
<ojhaapala@gmail.com>
Twitter: @olpetik
IRC: olpe
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of wht nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../config.js" as DB

Page {
    id: projectss
    allowedOrientations: Orientation.All
    function getProjects() {
        projects = DB.getProjects();
        for (var i = 0; i < projects.length; i++) {
            projectsModel.set(i, {
                'id': projects[i].id,
                'name': projects[i].name,
                'hourlyRate': projects[i].hourlyRate,
                'contractRate':projects[i].contractRate,
                'budget': projects[i].budget,
                'hourBudget': projects[i].hourBudget,
                'labelColor': projects[i].labelColor
            })
            //console.log(projects[i].id, projects[i].name, projects[i].hourlyRate, projects[i].contractRate, projects[i].budget, projects[i].hourBudget, projects[i].labelColor);
        }
    }
    SilicaFlickable{
        anchors.fill: parent
        ListModel {
            id: projectsModel
        }

        Component.onCompleted: {
            defaultProjectId = settings.getDefaultProjectId();
            //console.log("default project id: ", defaultProjectId);
            getProjects();
        }
        SilicaListView {
            id: listView
            header: PageHeader {
                title: qsTr("All projects")
            }
            PullDownMenu {
                MenuItem {
                    text: qsTr("Add project")
                    onClicked: {
                        //console.log (dataContainer)
                        pageStack.push(Qt.resolvedUrl("AddProject.qml"),{prev: projectss})
                    }
                }
            }
            spacing: Theme.paddingLarge
            anchors.fill: parent
            quickScroll: true
            model: projectsModel
            VerticalScrollDecorator {}

            ViewPlaceholder {
                        enabled: listView.count == 0
                        text: qsTr("No projects found")
            }
            delegate: Item {
                id: myListItem
                property Item contextMenu
                property bool menuOpen: contextMenu != null && contextMenu.parent === myListItem
                width: ListView.view.width
                height: menuOpen ? contextMenu.height + contentItem.childrenRect.height: contentItem.childrenRect.height

                BackgroundItem {
                    id: contentItem
                    width: parent.width
                    Rectangle{
                        height: 15
                        color: Theme.rgba(model.labelColor, Theme.highlightBackgroundOpacity)
                        anchors.fill: parent
                        Item {
                            width: childrenRect.width
                            y: Theme.paddingLarge
                            x: Theme.paddingLarge
                            Label {
                                id: projectName
                                text: model.name
                                font{
                                    bold: true
                                    pixelSize: Theme.fontSizeMedium
                                }
                            }
                            Label {
                                visible: model.id === defaultProjectId
                                id: defaultProjectLabel
                                text: "  (" + qsTr("Default project") + ")"
                                font{
                                    bold: true
                                    pixelSize: Theme.fontSizeMedium
                                }
                                anchors.left: projectName.right
                            }
                        }
                    }
                    onClicked: {
                        //console.log(model.id, model.name, model.hourlyRate, model.contractRate, model.budget, model.hourBudget, model.labelColor);
                        pageStack.push(Qt.resolvedUrl("AddProject.qml"),{
                                           prev: projectss,
                                           editMode: true,
                                           projectId: model.id,
                                           name: model.name,
                                           hourlyRate: model.hourlyRate,
                                           contractRate: model.contractRate,
                                           budget: model.budget,
                                           hourBudget: model.hourBudget,
                                           labelColor: model.labelColor
                                       })
                    }
                    onPressAndHold: {
                        if (!contextMenu)
                            contextMenu = contextMenuComponent.createObject(listView)
                        contextMenu.show(myListItem)
                    }
                }
                RemorseItem { id: remorse }
                function remove() {
                    //console.log(index)
                    //console.log(model.id)
                    remorse.execute(myListItem, qsTr("Removing"), function() {
                        DB.removeProject(model.id);
                        projectsModel.remove(index);
                        getProjects();
                    })
                }
            }
            Component {
               id: contextMenuComponent
               ContextMenu {
                   id: menu
                   MenuItem {
                       text: qsTr("Remove")
                       onClicked: {
                           menu.parent.remove();
                           //console.log("Remove clicked!")
                       }
                   }
               }
            }
        }
    }
}


